import 'package:cutie_mqtt/src/mqtt_qos.dart';
import 'package:cutie_mqtt/src/packets/subscribe_packet.dart';
import 'package:test/test.dart';

void main() {
  test("MqttPacketType.subscribe packet", () {
    expect(InternalSubscribePacket(0xBEEF, SubscribePacket([
      TopicSubscription("yeye ahh", MqttQos.exactlyOnce),
      TopicSubscription("no cap", MqttQos.atLeastOnce),
    ])).toBytes(), [
      0x82,23,
      0xBE,0xEF,
      0,
      0,8,..."yeye ahh".codeUnits,
      2,
      0,6,..."no cap".codeUnits,
      1,
    ]);
  },);
}