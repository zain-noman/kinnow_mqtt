import 'package:flutter/material.dart';
import 'package:kinnow_mqtt/kinnow_mqtt.dart';
import 'package:kinnow_mqtt_flutter_desktop_client/logs_provider.dart';
import 'package:kinnow_mqtt_flutter_desktop_client/mqtt_logs.dart';
import 'package:kinnow_mqtt_flutter_desktop_client/mqtt_provider.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void mqttEventHandler(MqttEvent event, BuildContext context) {
    switch (event) {
      case NetworkConnectionFailure():
        LogsProvider.of(context).addLog(GenericMqttEventLog(
            isSentByClient: true, title: "Network Connection Failure"));
      case NetworkEnded():
        LogsProvider.of(context).addLog(GenericMqttEventLog(
            isSentByClient: false,
            title: "Network Connection Closed by broker"));
      case MalformedPacket():
        LogsProvider.of(context).addLog(GenericMqttEventLog(
            isSentByClient: false,
            title: "Malformed Packet",
            data: {"info": event.message.toString()}));
      case ConnAckEvent():
        LogsProvider.of(context).addLog(GenericMqttEventLog(
            isSentByClient: false,
            title: "Connection Acknowledge",
            data: {
              "Connect Reason": event.connAck.connectReasonCode.name,
              "Session Present": event.connAck.sessionPresent.toString(),
              "Reason String": event.connAck.reasonString.toString(),
            }));
      case PingReqSent():
        LogsProvider.of(context).addLog(
          GenericMqttEventLog(isSentByClient: true, title: "Ping Request Sent"),
        );
      case PingRespReceived():
        LogsProvider.of(context).addLog(
          GenericMqttEventLog(
              isSentByClient: false, title: "Ping Response Received"),
        );
      case PingRespNotReceived():
        LogsProvider.of(context).addLog(
          GenericMqttEventLog(
              isSentByClient: false, title: "Ping Response Not Received"),
        );
      case ConnackTimedOut():
        LogsProvider.of(context).addLog(
          GenericMqttEventLog(
              isSentByClient: false, title: "ConnAck Not Received"),
        );
      case ShutDown():
        LogsProvider.of(context).addLog(
          GenericMqttEventLog(
              isSentByClient: true,
              title: "Client Shut Down",
              data: {"Shutdown reason": event.type.name}),
        );
      case StoredMessageSentQos0():
      // TODO: Handle this case.
      case StoredMessageSentQos1():
      // TODO: Handle this case.
      case StoredMessageSentQos2():
      // TODO: Handle this case.
    }
  }

  void onMessageReceived(RxPublishPacket message, BuildContext context) {
    LogsProvider.of(context).addLog(RxPublishPacketLog(message));
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kinnow Mqtt Demo',
      theme: ThemeData(
        colorScheme: ColorScheme(
            primary: Colors.orange,
            onPrimary: Colors.white,
            primaryContainer: Colors.orange.shade100,
            onPrimaryContainer: Colors.brown.shade900,
            secondary: Colors.green.shade200,
            onSecondary: Colors.green.shade800,
            secondaryContainer: Colors.green.shade200,
            onSecondaryContainer: Colors.green.shade600,
            brightness: Brightness.light,
            error: Colors.red,
            onError: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
            shadow: Colors.grey.shade300),
        useMaterial3: true,
      ),
      home: LogsProviderBase(
        child: MqttProviderBase(
          onMqttEvent: mqttEventHandler,
          onMessageReceive: onMessageReceived,
          child: const HomePage(),
        ),
      ),
    );
  }
}
