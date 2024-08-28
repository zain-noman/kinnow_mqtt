import 'package:cutie_mqtt/cutie_mqtt.dart';
import 'package:cutie_mqtt/src/byte_utils.dart';

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
  print(connPkt.toBytes("cutie_mqtt_${DateTime.now().millisecondsSinceEpoch}"));
  final connectionAck = await client.connect(connPkt);

  await Future.delayed(const Duration(seconds: 6));
  if (connectionAck == null) return;
  print(connectionAck);
  client.publishQos0(
    TxPublishPacket(
      false,
      "zainTestTopic",
      StringOrBytes.fromString(
          "joe mama so fat, she wouldn't fit in the mqtt size limit"),
    ),
  );
}