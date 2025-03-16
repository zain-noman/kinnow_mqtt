import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kinnow_mqtt/kinnow_mqtt.dart';
import 'package:kinnow_mqtt_flutter_example/mqtt_provider.dart';

import 'mqtt_action_selector.dart';

class ConnectActionMaker extends StatefulWidget {
  const ConnectActionMaker({super.key});

  @override
  State<ConnectActionMaker> createState() => _ConnectActionMakerState();
}

class _ConnectActionMakerState extends State<ConnectActionMaker>
    with AutomaticKeepAliveClientMixin {
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
    if (tlsEnabled) {
      networkConnection =
          SslTcpMqttNetworkConnection(() => SecureSocket.connect(host!, port!));
    } else {
      networkConnection = TcpMqttNetworkConnection(host!, port!);
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
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          StringNullableFormField("host", true, (p0) => host = p0),
          IntNullableFormField("port", true, (p0) => port = p0!),
          StringNullableFormField("client id", false, (p0) => clientId = p0),
          StringNullableFormField("username", false, (p0) => username = p0),
          StringNullableFormField("password", false, (p0) => password = p0),
          IntNullableFormField(
              "keep alive interval", true, (p0) => keepAliveInterval = p0!),
          BoolFormField("clean start", cleanStart,
              (p0) => setState(() => cleanStart = p0)),
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
          FilledButton(
            onPressed: onConnectPressed,
            child: const Text("Connect"),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
