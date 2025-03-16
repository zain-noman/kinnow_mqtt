import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:crclib/catalog.dart';
import 'package:kinnow_mqtt/kinnow_mqtt.dart';
import 'package:mutex/mutex.dart';
import 'dart:io';
import 'package:path/path.dart' as path_lib;
import 'proto/tx_publish_pkt_storage.pb.dart';

/// implements persistent storage pf Mqtt Messages in files
class FileMqttMessageStorage implements MqttMessageStorage {
  /// A directory where the files will be stored.
  final String storageDirectory;

  bool _dataSynced = false;
  IOSink? _dataSink;
  IOSink? _deletedIdsSink;
  String _clientId = "";
  final _mutex = Mutex();
  int _maxId = 0;

  /// create file based mqtt storage object,
  ///
  /// [shouldStoreMessage] can be used to specify which messages to store
  FileMqttMessageStorage(this.storageDirectory, {this.shouldStoreMessage});

  final Map<int, MqttMessageStorageRow> _storedMessagesCache = {};

  Future<SplayTreeSet<int>> _getDeletedIdsFromDelFile(
      File delFile, void Function() onCorruptionDetected) async {
    final deletedIds = SplayTreeSet<int>();
    Iterable<int> buf = [];
    await for (var bytes in delFile.openRead()) {
      buf = buf.followedBy(bytes);

      final validData = buf.take(buf.length - buf.length % 8);
      buf = buf.skip(buf.length - buf.length % 8);

      var delIdsAndInverse =
          Uint8List.fromList(validData.toList()).buffer.asUint32List();
      for (var i = 0; i < delIdsAndInverse.length; i += 2) {
        // inverted value used as checksum
        if (delIdsAndInverse[i] == (~delIdsAndInverse[i + 1]) & 0xFFFFFFFF) {
          deletedIds.add(delIdsAndInverse[i]);
        } else {
          onCorruptionDetected();
          return deletedIds;
        }
      }
    }
    return deletedIds;
  }

  Stream<MqttMessageStorageRow> _getDataFromDataFile(
      File dataFile, void Function() onCorruptionDetected) async* {
    Iterable<int> dataBuf = [];
    final strIter = StreamIterator(dataFile.openRead());
    bool fileOngoing = await strIter.moveNext();
    if (fileOngoing) {
      dataBuf = dataBuf.followedBy(strIter.current);
    }
    while (fileOngoing) {
      //try reading len
      while (dataBuf.length < 4) {
        fileOngoing = await strIter.moveNext();
        if (!fileOngoing) break;
        dataBuf = dataBuf.followedBy(strIter.current);
      }
      if (!fileOngoing) break;

      final lenBytes = dataBuf.take(4);
      final len =
          Uint8List.fromList(lenBytes.toList()).buffer.asUint32List()[0];
      dataBuf = dataBuf.skip(4);

      // get crc and payload
      while (dataBuf.length < 4 + len) {
        fileOngoing = await strIter.moveNext();
        if (!fileOngoing) {
          onCorruptionDetected();
          break;
        }
        dataBuf = dataBuf.followedBy(strIter.current);
      }
      if (!fileOngoing) break;

      final savedCrc =
          Uint8List.fromList(dataBuf.take(4).toList()).buffer.asUint32List()[0];
      final payload = dataBuf.skip(4).take(len);

      //crosscheck crc
      final calculatedCrc =
          Crc32().convert(payload.toList()).toBigInt().toInt();
      if (calculatedCrc != savedCrc) {
        onCorruptionDetected();
        break;
      }

      //parse and yield payload
      final proto = tx_publish_pkt_storage.fromBuffer(payload.toList());
      final txPkt = TxPublishPacket(
        proto.retain,
        proto.topic,
        StringOrBytes.fromBytes(proto.payload),
        useAlias: proto.useAlias,
        responseTopic: proto.hasResponseTopic() ? proto.responseTopic : null,
        payloadFormat: proto.hasPayloadFormat()
            ? (proto.payloadFormat
                ? MqttFormatIndicator.utf8
                : MqttFormatIndicator.bytes)
            : null,
        messageExpiryInterval: proto.hasMessageExpiryInterval()
            ? proto.messageExpiryInterval
            : null,
        correlationData:
            proto.hasCorrelationData() ? proto.correlationData : null,
        contentType: proto.hasContentType() ? proto.contentType : null,
        userProperties: proto.userProperties,
      );

      final row = MqttMessageStorageRow(
          txPkt, MqttQos.values[proto.qos], proto.storageId);

      if (row.storageId > _maxId) {
        _maxId = row.storageId;
      }

      yield row;

      dataBuf = dataBuf.skip(4 + len);
    }
  }

  Stream<MqttMessageStorageRow> _sync() async* {
    await _mutex.acquire();
    try {
      var fData = File(path_lib.join(storageDirectory, "$_clientId.bin"));
      var fDel = File(path_lib.join(storageDirectory, "$_clientId.del.bin"));
      bool corruptionDetected = false;

      //read deleted ids
      SplayTreeSet<int> deletedIds;
      deletedIds = await _getDeletedIdsFromDelFile(
        fDel,
        () => corruptionDetected = true,
      );

      // read stored data
      await for (final row in _getDataFromDataFile(
        fData,
        () => corruptionDetected = true,
      )) {
        if (!deletedIds.contains(row.storageId)) {
          yield row;
          _storedMessagesCache[row.storageId] = row;
        }
      }
      if (corruptionDetected) {
        // use cache to create new file
        await _deFragment();
        fData = File(path_lib.join(storageDirectory, "$_clientId.bin"));
        fDel = File(path_lib.join(storageDirectory, "$_clientId.del.bin"));
        fDel = await fDel.create();
      }

      _dataSynced = true;
      _dataSink = fData.openWrite(mode: FileMode.append);
      _deletedIdsSink = fDel.openWrite(mode: FileMode.append);
    } finally {
      _mutex.release();
    }
  }

  Future<void> _deFragment() async {
    final fDataNew =
        File(path_lib.join(storageDirectory, "$_clientId.bin.new"));
    await fDataNew.create();
    final fDataNewIoSink = fDataNew.openWrite();

    for (var x in _storedMessagesCache.values) {
      fDataNewIoSink.add(_rowToBytes(x));
    }
    await fDataNewIoSink.flush();

    final fDel = File(path_lib.join(storageDirectory, "$_clientId.del.bin"));
    if (await fDel.exists()) {
      await fDel.delete();
    }
    await fDataNew.rename(path_lib.join(storageDirectory, "$_clientId.bin"));
  }

  List<int> _rowToBytes(MqttMessageStorageRow row) {
    final proto = tx_publish_pkt_storage()
      ..storageId = row.storageId
      ..qos = row.qos.index
      ..payload = row.packet.payload.asBytes
      ..userProperties.addAll(row.packet.userProperties)
      ..retain = row.packet.retain
      ..topic = row.packet.topic
      ..useAlias = row.packet.useAlias;
    if (row.packet.payloadFormat != null) {
      proto.payloadFormat =
          row.packet.payloadFormat == MqttFormatIndicator.utf8;
    }
    if (row.packet.messageExpiryInterval != null) {
      proto.messageExpiryInterval = row.packet.messageExpiryInterval!;
    }
    if (row.packet.responseTopic != null) {
      proto.responseTopic = row.packet.responseTopic!;
    }
    if (row.packet.correlationData != null) {
      proto.correlationData = row.packet.correlationData!;
    }
    if (row.packet.contentType != null) {
      proto.contentType = row.packet.contentType!;
    }

    final buf = proto.writeToBuffer();
    final byteBuf = ByteData(8);
    byteBuf.setUint32(0, buf.length, Endian.little);
    final crc = Crc32().convert(buf.toList()).toBigInt().toInt();
    byteBuf.setUint32(4, crc, Endian.little);

    return [...byteBuf.buffer.asUint8List(), ...buf];
  }

  @override
  Stream<MqttMessageStorageRow> fetchAll() {
    if (!_dataSynced) {
      return _sync();
    } else {
      return Stream.fromIterable(_storedMessagesCache.values);
    }
  }

  @override
  Future<void> initialize(String clientId) async {
    _clientId = clientId;

    var fData = File(path_lib.join(storageDirectory, "$_clientId.bin"));
    if (!(await fData.exists())) {
      await fData.create();
    }

    var fDel = File(path_lib.join(storageDirectory, "$_clientId.del.bin"));
    if (!(await fDel.exists())) {
      await fDel.create();
    }
  }

  @override
  Future<void> remove(int idToRemove) async {
    if (!_dataSynced) {
      await _sync().drain();
    }
    _storedMessagesCache.remove(idToRemove);
    final buf = ByteData(8)
      ..setUint32(0, idToRemove, Endian.little)
      ..setUint32(4, (~idToRemove) & 0xFFFFFFFF, Endian.little);

    await _mutex.protect(
      () async {
        _deletedIdsSink!.add(buf.buffer.asUint8List());
      },
    );
  }

  @override
  Future<int?> storeMessage(MqttQos qos, TxPublishPacket publishPkt) async {
    if (shouldStoreMessage != null &&
        shouldStoreMessage!(qos, publishPkt) == false) {
      return null;
    }

    _maxId++;
    if (!_dataSynced) {
      await _sync().drain();
    }
    final row = MqttMessageStorageRow(publishPkt, qos, _maxId);
    _storedMessagesCache[_maxId] = row;
    await _mutex.protect(
      () async {
        _dataSink!.add(_rowToBytes(row));
      },
    );
    return _maxId;
  }

  @override
  Future<void> dispose() async {
    await _dataSink?.close();
    await _deletedIdsSink?.close();
  }

  @override
  bool Function(MqttQos qos, TxPublishPacket publishPkt)? shouldStoreMessage;
}
