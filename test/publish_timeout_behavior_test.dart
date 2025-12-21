import 'dart:async';

import 'package:kinnow_mqtt/src/mqtt_fixed_header.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:kinnow_mqtt/kinnow_mqtt.dart';
import 'package:kinnow_mqtt/src/mqtt_packet_types.dart';

class TestNetworkConnection implements MqttNetworkConnection {
  // adding to this stream will send data to the client
  StreamController<int>? controller;
  bool _enabled = true;

  // this stream will contain packets sent by the client to the broker
  final StreamController<MqttPacketType> packetReceivedController =
      StreamController<MqttPacketType>.broadcast();

  @override
  Future<Stream<int>?> connect() async {
    if (_enabled) {
      controller = StreamController<int>();
      return controller!.stream;
    } else {
      return null;
    }
  }

  @override
  Future<bool> transmit(Iterable<int> bytes) async {
    final parseRes = MqttFixedHeader.fromBytes(bytes);
    if (parseRes?.data.packetType != null) {
      packetReceivedController.add(parseRes!.data.packetType);
    }
    return true;
  }

  @override
  Future<void> close() async {
    print("Mock network connection closed");
  }

  void setEnabled(bool enabled) {
    if (!enabled) {
      controller?.close();
      controller = null;
    }
    _enabled = enabled;
  }
}

void main() {
  group(
    "timeout_behavior",
    () {
      test(
        "Qos0 timeout Behavior",
        timeout: Timeout(const Duration(seconds: 120)),
        () async {
          final net = TestNetworkConnection();
          net.packetReceivedController.stream.listen(
            (event) {
              print("Packet sent by client ${event.name}");
              if (event != MqttPacketType.pingreq) return;
              print("ping request received by server");
              for (final i
                  in MqttFixedHeader(MqttPacketType.pingresp, 0, 0).toBytes()) {
                net.controller?.add(i);
              }
            },
          );

          final c =
              KinnowMqttClient(net, reconnectDelay: const Duration(seconds: 1));
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
          // send a conn ack
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

          await Future.delayed(const Duration(seconds: 3));

          // simulate network disconnection;
          net.setEnabled(false);

          await Future.delayed(const Duration(seconds: 1));

          // send a qos0 message which will fail due to timeout
          final startTimePubFail = DateTime.now();
          final qos0PublishFailStatus = await c.publishQos0(
              TxPublishPacket(false, "Test", StringOrBytes.fromString("Test")),
              timeout: const Duration(seconds: 3));
          final elapsedTimePubFail =
              DateTime.now().difference(startTimePubFail).inMilliseconds;
          expect(qos0PublishFailStatus, false);
          expect(elapsedTimePubFail, lessThan(5000));

          await Future.delayed(const Duration(seconds: 1));

          // send a message but reconnect within the timeout
          // this should publish successfully
          final startTimePubSuccess = DateTime.now();
          bool qos0PublishSuccessStatus = false;
          int elapsedTimePubSuccess = 99999;
          c
              .publishQos0(
                  TxPublishPacket(
                    false,
                    "Test",
                    StringOrBytes.fromString("Test"),
                  ),
                  timeout: const Duration(seconds: 5))
              .then((value) {
            qos0PublishSuccessStatus = value;
            elapsedTimePubSuccess =
                DateTime.now().difference(startTimePubSuccess).inMilliseconds;
          });

          await Future.delayed(const Duration(seconds: 2));
          // now we should be able to reconnect
          net.setEnabled(true);
          await Future.delayed(const Duration(seconds: 1));
          // send a conn ack
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
          await Future.delayed(const Duration(seconds: 2));

          expect(qos0PublishSuccessStatus,true);
          expect(elapsedTimePubSuccess, lessThan(6000));
        },
      );
    },
  );
}
