import 'package:kinnow_mqtt/kinnow_mqtt.dart';
import 'package:test/test.dart';

class DisconnectingNetwork extends TcpMqttNetworkConnection {
  bool _enabled = true;

  DisconnectingNetwork(super.host, super.port);

  @override
  Future<Stream<int>?> connect() {
    if (!_enabled) return Future.value(null);
    return super.connect();
  }

  void setEnabled(bool enabled) {
    if (!enabled) {
      super.close();
    }
    _enabled = enabled;
  }
}

void main() {
  test("persistent messages test",
      timeout: Timeout(const Duration(seconds: 240)), () async {
    final disconnectingNetwork = DisconnectingNetwork("localhost", 1883);
    final subClient = KinnowMqttClient(disconnectingNetwork);
    final connPkt = ConnectPacket(
        cleanStart: true,
        lastWill: null,
        keepAliveSeconds: 5,
        username: null,
        password: null,
        sessionExpiryIntervalSeconds: 120);
    final eventStream = subClient.begin(connPkt);
    eventStream.listen(
      (event) => print("sub client event: ${event.runtimeType}"),
    );
    final connack = (await eventStream
        .firstWhere((element) => element is ConnAckEvent)) as ConnAckEvent;
    expect(connack, isNotNull);
    expect(connack.connAck.connectReasonCode, ConnectReasonCode.success);

    int numMessagesReceived = 0;
    subClient.receivedMessagesStream.listen(
      (event) {
        print("Message Received: ${event.payload.asString}");
        numMessagesReceived++;
      },
    );

    final suback = await subClient.subscribe(SubscribePacket(
        [TopicSubscription("persistenceTest", MqttQos.exactlyOnce)]));
    expect(suback, isNotNull);

    final pubClient =
        KinnowMqttClient(TcpMqttNetworkConnection("localhost", 1883));
    final pubClientEvents = pubClient.begin(ConnectPacket(
        cleanStart: true,
        lastWill: null,
        keepAliveSeconds: 5,
        username: null,
        password: null));
    pubClientEvents.listen(
      (event) => print("pub client event: ${event.runtimeType}"),
    );
    final pubClientConnack = (await pubClientEvents
        .firstWhere((element) => element is ConnAckEvent)) as ConnAckEvent;
    expect(pubClientConnack, isNotNull);
    expect(
        pubClientConnack.connAck.connectReasonCode, ConnectReasonCode.success);

    await pubClient.publishQos2(TxPublishPacket(
        false, "persistenceTest", StringOrBytes.fromString("pkt 1")));

    await Future.delayed(const Duration(seconds: 5));
    disconnectingNetwork.setEnabled(false);

    await Future.delayed(const Duration(seconds: 20));

    await pubClient.publishQos2(TxPublishPacket(
        false, "persistenceTest", StringOrBytes.fromString("pkt 2")));

    await pubClient.publishQos2(TxPublishPacket(
        false, "persistenceTest", StringOrBytes.fromString("pkt 3")));

    await pubClient.publishQos2(TxPublishPacket(
        false, "persistenceTest", StringOrBytes.fromString("pkt 4")));

    await Future.delayed(const Duration(seconds: 5));
    disconnectingNetwork.setEnabled(true);
    await Future.delayed(const Duration(seconds: 15));

    expect(numMessagesReceived, 4);
    pubClient.disconnect();
    await pubClientEvents.firstWhere((element) => element is ShutDown);
    subClient.disconnect();
    await eventStream.firstWhere((element) => element is ShutDown);
  });
}
