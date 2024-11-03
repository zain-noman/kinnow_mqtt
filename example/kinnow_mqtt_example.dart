import 'package:kinnow_mqtt/kinnow_mqtt.dart';

void main() async {
  final client = KinnowMqttClient(
      TcpMqttNetworkConnection("your.brokers.address.here.com", 1883));
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
  await client.publishQos0(TxPublishPacket(
    false,
    "kinnowTestTopic",
    StringOrBytes.fromString("A QoS 0 message"),
  ));

  final puback = await client.publishQos1(TxPublishPacket(
      false, "kinnowTestTopic", StringOrBytes.fromString("A QoS1 message")));

  if (puback != null) {
    print("puback received");
  }

  final qos2res = await client.publishQos2(TxPublishPacket(
      false, "kinnowTestTopic", StringOrBytes.fromString("A QoS2 message")));

  if (qos2res != null) {
    print("pubrec and pubcomp received");
  }

  final suback = await client.subscribe(SubscribePacket([
    TopicSubscription("KinnowSubTopic1", MqttQos.atMostOnce),
    TopicSubscription("KinnowSubTopic2", MqttQos.atLeastOnce),
    TopicSubscription("KinnowSubTopic3", MqttQos.exactlyOnce),
  ]));
  if (suback != null) {
    print("suback received");
    int idx = 0;
    for (final reason in suback.reasonCodes) {
      print("topic $idx success ${reason.name}");
      idx++;
    }
  }

  client.receivedMessagesStream.listen(
    (event) => print("Packet Received "
        "\n \t topic: ${event.topic},"
        "\n \t qos: ${event.qos},"
        "\n \t payload: ${event.payload.asString}"),
  );

  await Future.delayed(const Duration(seconds: 15));
  client.disconnect();
}
