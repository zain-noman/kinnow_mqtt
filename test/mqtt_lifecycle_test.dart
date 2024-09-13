import 'dart:async';
import 'package:cutie_mqtt/cutie_mqtt.dart';
import 'package:cutie_mqtt/src/disconnect_packet.dart';
import 'package:cutie_mqtt/src/mqtt_fixed_header.dart';
import 'package:cutie_mqtt/src/mqtt_packet_types.dart';
import 'package:test/test.dart';

class UnresponsiveNetworkConnection implements MqttNetworkConnection {
  final StreamController<int> controller = StreamController<int>();

  @override
  Future<Stream<int>?> connect() async {
    return null;
  }

  @override
  Future<bool> transmit(Iterable<int> bytes) async {
    return false;
  }
}

class TestNetworkConnection implements MqttNetworkConnection {
  StreamController<int>? controller;
  final StreamController<MqttPacketType> packetReceivedControlller =
      StreamController<MqttPacketType>.broadcast();

  @override
  Future<Stream<int>?> connect() async {
    controller = StreamController<int>();
    return controller!.stream;
  }

  @override
  Future<bool> transmit(Iterable<int> bytes) async {
    final parseRes = MqttFixedHeader.fromBytes(bytes);
    if (parseRes?.data.packetType != null) {
      packetReceivedControlller.add(parseRes!.data.packetType);
    }
    return true;
  }
}

void main() {
  group(
    "lifecycle",
    () {
      test(
        "unresponsive network",
        () async {
          final net = UnresponsiveNetworkConnection();
          final c = CutieMqttClient(net);
          final eventStream = c.begin(ConnectPacket(
              cleanStart: false,
              lastWill: null,
              keepAliveSeconds: 5,
              username: null,
              password: null));
          final strIter = StreamIterator(eventStream);
          await strIter.moveNext();
          expect(strIter.current, isA<NetworkConnectionFailure>());
          await strIter.moveNext();
          expect(strIter.current, isA<NetworkConnectionFailure>());
          await strIter.cancel();
        },
      );
      test(
        "connection lifecycle normal",
        () async {
          final net = TestNetworkConnection();
          net.packetReceivedControlller.stream.listen(
            (event) {
              if (event != MqttPacketType.pingreq) return;
              print("ping request received by server");
              for (final i
                  in MqttFixedHeader(MqttPacketType.pingresp, 0, 0).toBytes()) {
                net.controller?.add(i);
              }
            },
          );

          final c = CutieMqttClient(net);
          final eventStream = c.begin(ConnectPacket(
              cleanStart: false,
              lastWill: null,
              keepAliveSeconds: 5,
              username: null,
              password: null));
          final eventsList = <MqttEvent>[];
          eventStream.listen(
            (event) => eventsList.add(event),
          );
          await Future.delayed(const Duration(seconds: 1));
          for (final i in [
            0x20,
            0x09,
            0x00,
            0x00,
            0x06,
            0x21,
            0x00,
            0x0a,
            0x22,
            0x00,
            0x05
          ]) {
            net.controller?.add(i);
          }
          await Future.delayed(const Duration(seconds: 7));
          expect(
              eventsList,
              containsAllInOrder([
                isA<ConnAckEvent>(),
                isA<PingReqSent>(),
                isA<PingRespReceived>()
              ]));
        },
      );
      test(
        "connection lifecycle pingTimeout",
        () async {
          final net = TestNetworkConnection();
          final c = CutieMqttClient(net);
          final eventStream = c.begin(ConnectPacket(
              cleanStart: false,
              lastWill: null,
              keepAliveSeconds: 5,
              username: null,
              password: null));
          final eventsList = <MqttEvent>[];
          eventStream.listen(
            (event) => eventsList.add(event),
          );
          final connectionStatusEvents = <bool>[];
          c.connectionStatusStream.listen(
            (event) => connectionStatusEvents.add(event),
          );
          await Future.delayed(const Duration(seconds: 1));
          final connackBytes = [
            0x20,
            0x09,
            0x00,
            0x00,
            0x06,
            0x21,
            0x00,
            0x0a,
            0x22,
            0x00,
            0x05
          ];
          for (final i in connackBytes) {
            net.controller?.add(i);
          }
          await Future.delayed(const Duration(seconds: 10));
          expect(
              eventsList,
              containsAllInOrder([
                isA<ConnAckEvent>(),
                isA<PingReqSent>(),
                isA<PingRespNotReceived>(),
              ]));
          expect(connectionStatusEvents, containsAllInOrder([true, false]));

          final connack = await Future.any([
            Future.delayed(const Duration(seconds: 10), () => null),
            net.packetReceivedControlller.stream
                .firstWhere((element) => element == MqttPacketType.connect)
          ]);
          expect(connack, isNotNull);
          //resend connack
          for (final i in connackBytes) {
            net.controller?.add(i);
          }
          await Future.delayed(const Duration(seconds: 1));
          expect(
              eventsList,
              containsAllInOrder([
                isA<ConnAckEvent>(),
                isA<PingReqSent>(),
                isA<PingRespNotReceived>(),
                isA<ConnAckEvent>(),
              ]));
          expect(
              connectionStatusEvents, containsAllInOrder([true, false, true]));
        },
      );
      test(
        "disconnect during Network disconnected",
        () async {
          final net = TestNetworkConnection();
          final c = CutieMqttClient(net);
          final eventStream = c.begin(ConnectPacket(
              cleanStart: false,
              lastWill: null,
              keepAliveSeconds: 60,
              username: null,
              password: null));
          bool eventStreamDone = false;
          final eventsList = <MqttEvent>[];
          eventStream.listen((event) => eventsList.add(event),
              onDone: () => eventStreamDone = true);
          final connectionStatusEvents = <bool>[];
          c.connectionStatusStream.listen(
            (event) => connectionStatusEvents.add(event),
          );
          c.disconnect();
          await Future.delayed(const Duration(seconds: 5));
          expect(eventsList, contains(isA<ShutDown>()));
          expect(eventsList.whereType<ShutDown>().first.type,
              ShutdownType.clientInitiatedNetworkUnavailable);
          expect(eventsList.whereType<ShutDown>().first.disconnectPacket, null);
          expect(eventStreamDone, true);
        },
      );
      test(
        "disconnect during Network connected",
        () async {
          final net = TestNetworkConnection();
          final c = CutieMqttClient(net);
          final eventStream = c.begin(ConnectPacket(
              cleanStart: false,
              lastWill: null,
              keepAliveSeconds: 60,
              username: null,
              password: null));
          bool eventStreamDone = false;
          final eventsList = <MqttEvent>[];
          eventStream.listen((event) => eventsList.add(event),
              onDone: () => eventStreamDone = true);
          final connectionStatusEvents = <bool>[];
          c.connectionStatusStream.listen(
            (event) => connectionStatusEvents.add(event),
          );

          final packetsSentToServer = <MqttPacketType>[];
          net.packetReceivedControlller.stream
              .listen((event) => packetsSentToServer.add(event));
          await net.packetReceivedControlller.stream.firstWhere(
            (element) => element == MqttPacketType.connect,
          );
          net.controller?.addStream(Stream.fromIterable([
            0x20,
            0x09,
            0x00,
            0x00,
            0x06,
            0x21,
            0x00,
            0x0a,
            0x22,
            0x00,
            0x05
          ]));
          await Future.delayed(const Duration(seconds: 2));
          c.disconnect(
              disconnectPkt: DisconnectPacket(DisconnectReasonCode.normal,
                  reasonString: "skibidi"));
          await Future.delayed(const Duration(seconds: 2));
          expect(packetsSentToServer, contains(MqttPacketType.disconnect));
          expect(eventsList, contains(isA<ShutDown>()));
          expect(eventsList.whereType<ShutDown>().first.type,
              ShutdownType.clientInitiated);
          expect(eventsList.whereType<ShutDown>().first.disconnectPacket,
              isNotNull);
          expect(
              eventsList
                  .whereType<ShutDown>()
                  .first
                  .disconnectPacket
                  ?.reasonString,
              "skibidi");
          expect(eventStreamDone, true);
        },
      );
    },
  );
}
