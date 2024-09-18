import 'package:cutie_mqtt/cutie_mqtt.dart';
import 'package:cutie_mqtt/src/mqtt_qos.dart';
import 'package:cutie_mqtt/src/packets/subscribe_packet.dart';

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
  await client.publishQos0(TxPublishPacket(
    false,
    "zainTestTopic",
    StringOrBytes.fromString(
        "joe mama so fat, she wouldn't fit in the mqtt size limit"),
  ));

  final puback = await client.publishQos1(TxPublishPacket(
      false,
      "zainTestTopic",
      StringOrBytes.fromString(
          "joe mama so old, she still using mqtt v3.1.1")));

  if (puback != null) {
    print("puback received");
  }

  /*
  final qos2res = await client.publishQos2(TxPublishPacket(
      false,
      "zainTestTopic",
      StringOrBytes.fromString(
          "joe mama so dumb, her mqtt client needs to be connected to send messages")));

  if (qos2res != null) {
    print("pubrec and pubcomp received");
  }
   */

  final suback = await client.subscribe(SubscribePacket([
    TopicSubscription("likeShareAndSubscribe", MqttQos.atMostOnce),
    TopicSubscription("MistOrBeast", MqttQos.atLeastOnce),
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
        "\n \t payload: ${event.payload.asString}"
    ),
  );
}
