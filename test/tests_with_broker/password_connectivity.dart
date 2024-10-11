import 'package:kinnow_mqtt/kinnow_mqtt.dart';
import 'package:test/test.dart';

void main() {
  test("Successful Password Auth", () async {
    final client =
        KinnowMqttClient(TcpMqttNetworkConnection("localhost", 1883));
    final connPkt = ConnectPacket(
      cleanStart: true,
      lastWill: null,
      keepAliveSeconds: 5,
      username: "WutIsLuv",
      password: StringOrBytes.fromString("BabyDontHurtMe"),
    );
    final eventStream = client.begin(connPkt);
    eventStream.listen(
      (event) => print(event.runtimeType),
    );
    final connack = (await eventStream
        .firstWhere((element) => element is ConnAckEvent)) as ConnAckEvent;
    expect(connack, isNotNull);
    expect(connack.connAck.connectReasonCode, ConnectReasonCode.success);
  });
  test("Unsuccessful Password Auth", () async {
    final client =
        KinnowMqttClient(TcpMqttNetworkConnection("localhost", 1883));
    final connPkt = ConnectPacket(
      cleanStart: true,
      lastWill: null,
      keepAliveSeconds: 5,
      username: "WutIsLuv",
      password: StringOrBytes.fromString("AHumanEmotion"),
    );
    final eventStream = client.begin(connPkt);

    final eventList = <MqttEvent>[];
    eventStream.listen(
      (event) {
        print(event.runtimeType);
        eventList.add(event);
      },
    );

    final connack = (await eventStream
        .firstWhere((element) => element is ConnAckEvent)) as ConnAckEvent;
    expect(connack, isNotNull);
    expect(connack.connAck.connectReasonCode,
        ConnectReasonCode.notAuthorized);
    await Future.delayed(const Duration(seconds: 2));
    expect(eventList.last, isA<ShutDown>());
  });
}
