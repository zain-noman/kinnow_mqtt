import 'package:cutie_mqtt/cutie_mqtt.dart';

void main() async {
  final client =
      CutieMqttClient(TcpMqttNetworkConnection("broker.hivemq.com", 1883));
  final connPkt = ConnectPacket(
    cleanStart: true,
    lastWill: null,
    keepAliveSeconds: 60,
    username: null,
    password: null,
  );
  final eventStream = client.begin(connPkt);
  eventStream.listen(
    (event) => print(event.runtimeType),
  );
  await client.publishQos0(
    TxPublishPacket(
      false,
      "zainTestTopic",
      StringOrBytes.fromString(
          "joe mama so fat, she wouldn't fit in the mqtt size limit"),
    ),
    discardIfNotConnected: false,
  );

  final puback = await client.publishQos1(TxPublishPacket(
      false,
      "zainTestTopic",
      StringOrBytes.fromString(
          "joe mama so old, she still using mqtt v3.1.1")));

  if (puback != null) {
    print("puback received");
  }
}
