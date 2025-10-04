import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kinnow_mqtt/kinnow_mqtt.dart';
import 'package:kinnow_mqtt_flutter_desktop_client/logs_provider.dart';
import 'package:kinnow_mqtt_flutter_desktop_client/mqtt_logs.dart';
import 'package:kinnow_mqtt_flutter_desktop_client/mqtt_provider.dart';

import 'mqtt_action_selector.dart';

class ConnectActionMaker extends StatefulWidget {
  const ConnectActionMaker({super.key});

  @override
  State<ConnectActionMaker> createState() => _ConnectActionMakerState();
}

class _ConnectActionMakerState extends State<ConnectActionMaker>
    with AutomaticKeepAliveClientMixin {
  bool useWebSockets = false;
  String? host;
  int? port;
  String? clientId;
  String? username;
  String? password;
  bool cleanStart = false;
  bool tlsEnabled = false;
  int? keepAliveInterval;
  bool useLastWill = false;
  int? sessionExpiryInterval;
  int? receiveMaximum;
  int? maxRecvPacketSize;
  int? topicAliasMax;
  bool? requestResponseInformation;
  bool? requestProblemInformation;
  MqttQos? willQos;
  bool willRetain = false;
  String? willTopic;
  StringOrBytes? willPayload;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void onConnectPressed() {
    if (_formKey.currentState!.validate() == false) {
      return;
    }
    _formKey.currentState!.save();

    final MqttNetworkConnection networkConnection;
    if (useWebSockets) {
        networkConnection = WebSocketMqttNetworkConnection(url: host!);
    } else {
      if (tlsEnabled) {
        networkConnection = SslTcpMqttNetworkConnection(
            () => SecureSocket.connect(host!, port!));
      } else {
        networkConnection = TcpMqttNetworkConnection(host!, port!);
      }
    }

    final ConnectPacketWillProperties? will;
    if (useLastWill) {
      will = ConnectPacketWillProperties(
          willQos!, willRetain, willTopic!, willPayload!);
    } else {
      will = null;
    }

    final connectPacket = ConnectPacket(
      cleanStart: cleanStart,
      lastWill: will,
      keepAliveSeconds: keepAliveInterval!,
      username: username,
      password: (password == null) ? null : StringOrBytes.fromString(password!),
      sessionExpiryIntervalSeconds: sessionExpiryInterval,
      receiveMaximum: receiveMaximum,
      maxRecvPacketSize: maxRecvPacketSize,
      topicAliasMax: topicAliasMax,
      requestResponseInformation: requestResponseInformation,
      requestProblemInformation: requestProblemInformation,
    );

    MqttProvider.of(context)
        .updateClient(connectPacket, networkConnection, clientId: clientId);
    LogsProvider.of(context).addLog(GenericMqttEventLog(
        isSentByClient: true,
        title: "Client Initialized",
        data: {
          "host": host.toString(),
          "port": port.toString(),
          "client Id": clientId.toString(),
          "username": username.toString(),
          "password": password.toString(),
          "clean start": cleanStart.toString(),
          "tls enabled": tlsEnabled.toString(),
          "keep alive interval": keepAliveInterval.toString(),
          "session expiry interval": sessionExpiryInterval.toString(),
          "receive maximum": receiveMaximum.toString(),
          "max recv packet size": maxRecvPacketSize.toString(),
          "topic alias max": topicAliasMax.toString(),
          "request response information": requestResponseInformation.toString(),
          "request problem information": requestProblemInformation.toString(),
          "use last will": useLastWill.toString(),
          if (useLastWill) ...{
            "will qos": willQos.toString(),
            "will retain": willRetain.toString(),
            "will topic": willTopic.toString(),
            "will payload": willPayload.toString(),
          }
        }));
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      useWebSockets = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 10),
          InfoButton(infoBuilder: infoWidget),
          StringNullableFormField("host", true, (p0) => host = p0),
          if (!useWebSockets)
            IntNullableFormField("port", true, (p0) => port = p0!),
          if (kIsWeb) const Text("On Browsers, only websockets are supported"),
          BoolFormField("use websockets?", useWebSockets, (p0) {
            if (!kIsWeb) setState(() => useWebSockets = p0);
          }),
          IntNullableFormField(
              "keep alive interval", true, (p0) => keepAliveInterval = p0!),
          StringNullableFormField("client id", false, (p0) => clientId = p0),
          StringNullableFormField("username", false, (p0) => username = p0),
          StringNullableFormField("password", false, (p0) => password = p0),
          BoolFormField("clean start", cleanStart,
              (p0) => setState(() => cleanStart = p0)),
          if (!useWebSockets)
            BoolFormField("use SSL/TLS", tlsEnabled,
                (p0) => setState(() => tlsEnabled = p0)),
          BoolFormField("use last will", useLastWill,
              (p0) => setState(() => useLastWill = p0)),
          if (useLastWill)
            ExpansionTile(
              title: const Text("Last Will"),
              children: [
                EnumFormField("Will QoS", true, MqttQos.values.asNameMap(),
                    (p0) => willQos = p0),
                BoolFormField(
                    "Will Retain", willRetain, (p0) => willRetain = p0),
                StringNullableFormField(
                    "Will Topic", true, (p0) => willTopic = p0),
                StringOrBytesNullableFormField(
                    "Will Payload", true, (p0) => willPayload = p0)
              ],
            ),
          ExpansionTile(
            title: const Text("Advanced"),
            children: [
              IntNullableFormField("session expiry interval", false,
                  (p0) => sessionExpiryInterval = p0),
              IntNullableFormField(
                  "receive maximum", false, (p0) => receiveMaximum = p0),
              IntNullableFormField("max receive packet size", false,
                  (p0) => maxRecvPacketSize = p0),
              IntNullableFormField(
                  "topic alias max", false, (p0) => topicAliasMax = p0),
              BoolNullableFormField(
                  "request response information",
                  requestResponseInformation,
                  (p0) => setState(() => requestResponseInformation = p0)),
              BoolNullableFormField(
                  "request problem information",
                  requestProblemInformation,
                  (p0) => setState(() => requestProblemInformation = p0)),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: onConnectPressed,
            child: const Text("Connect"),
          )
        ],
      ),
    );
  }

  Widget infoWidget(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Host",
          style: titleStyle,
        ),
        const Text("Ip address or uri of the mqtt broker"),
        Text(
          "Port",
          style: titleStyle,
        ),
        const Text("The port for socket connection. 1883 is commonly used"),
        Text("Keep Alive Interval", style: titleStyle),
        Text("Client Id", style: titleStyle),
        const Text(
            "A unique identifier of the client.Please ensure using unique clientIds on different devices. If the same clientId is used, disconnections may occur."),
        Text("Username", style: titleStyle),
        const Text("username for username + password based authentication"),
        Text("Password", style: titleStyle),
        const Text(
            "password for username + password based authentication. Does not necessarily need to be a string"),
        Text("Clean Start", style: titleStyle),
        const Text(
            "if 'true', any previous state stored by the server is discarded, otherwise it is used"),
        Text("Tls Enabled", style: titleStyle),
        const Text(
            "Enabling TLS makes your connection secure from being spied on"),
        Text("Session Expiry Interval", style: titleStyle),
        const Text(
            "the server will delete the 'state' of the client this many seconds after network disconnection"),
        Text("Receive Maximum", style: titleStyle),
        const Text(
            "the maximum number of in progress QoS1 and QoS2 messages that the client can handle at a time. The library does not currently use this value to limit the message rate"),
        Text("Max Receive Packet Size", style: titleStyle),
        const Text(
            "messages larger than this size will not be forwarded by the broker to this client"),
        Text("Topic Alias Max", style: titleStyle),
        const Text("the maximum number of topics aliases to be used"),
        Text("Request Response Information", style: titleStyle),
        const Text(
            "if 'true' the server should send responseInformation in the ConnAckPacket"),
        Text("Request Problem Information", style: titleStyle),
        const Text("whether the server will send reason strings on packets"),
        Text("Will Qos", style: titleStyle),
        const Text("The Qos of the last will packet"),
        Text("Will Retain", style: titleStyle),
        const Text("The retain of the last will packet"),
        Text("Will Topic", style: titleStyle),
        const Text("The topic of the last will packet"),
        Text("Will Payload", style: titleStyle),
        const Text("The Payload of the last will packet"),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
