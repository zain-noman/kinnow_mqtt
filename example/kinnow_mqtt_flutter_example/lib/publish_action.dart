import "package:flutter/material.dart";
import "package:kinnow_mqtt/kinnow_mqtt.dart";
import "package:kinnow_mqtt_flutter_example/logs_provider.dart";
import "package:kinnow_mqtt_flutter_example/mqtt_action_selector.dart";
import "package:kinnow_mqtt_flutter_example/mqtt_logs.dart";
import "package:kinnow_mqtt_flutter_example/mqtt_provider.dart";

class PublishAction extends StatefulWidget {
  const PublishAction({super.key});

  @override
  State<PublishAction> createState() => _PublishActionState();
}

class _PublishActionState extends State<PublishAction> {
  bool retain = false;
  String? topic;
  StringOrBytes? payload;
  MqttQos? qos;

  bool useAlias = false;
  MqttFormatIndicator? payloadFormat;
  int? messageExpiryInterval;
  String? responseTopic;
  StringOrBytes? correlationData;
  String? contentType;

  final _formKey = GlobalKey<FormState>();

  void onPublishPressed() {
    if (_formKey.currentState!.validate() == false) {
      return;
    }
    _formKey.currentState!.save();

    final pkt = TxPublishPacket(
      retain,
      topic!,
      payload!,
      useAlias: useAlias,
      payloadFormat: payloadFormat,
      messageExpiryInterval: messageExpiryInterval,
      responseTopic: responseTopic,
      correlationData: correlationData?.asBytes,
      contentType: contentType,
    );

    switch (qos!) {
      case MqttQos.atMostOnce:
        final responseFut = MqttProvider.of(context).client!.publishQos0(pkt);
        LogsProvider.of(context)
            .addLog(TxPublishPacketLogQos0(pkt, responseFut));
      case MqttQos.atLeastOnce:
        final responseFut = MqttProvider.of(context).client!.publishQos1(pkt);
        LogsProvider.of(context)
            .addLog(TxPublishPacketLogQos1(pkt, responseFut));
      case MqttQos.exactlyOnce:
        final responseFut = MqttProvider.of(context).client!.publishQos2(pkt);
        LogsProvider.of(context)
            .addLog(TxPublishPacketLogQos2(pkt, responseFut));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: [
          StringNullableFormField("topic", true, (p0) => topic = p0),
          StringOrBytesNullableFormField("payload", true, (p0) => payload = p0),
          BoolFormField(
            "retain",
            retain,
            (p0) => setState(() {
              retain = p0;
            }),
          ),
          EnumFormField(
              "qos", true, MqttQos.values.asNameMap(), (p0) => qos = p0),
          ExpansionTile(title: const Text("Advanced"), children: [
            BoolFormField(
                "use alias",
                useAlias,
                (p0) => setState(() {
                      useAlias = p0;
                    })),
            EnumFormField(
                "payload format",
                false,
                MqttFormatIndicator.values.asNameMap(),
                (p0) => payloadFormat = p0),
            IntNullableFormField("message Expiry Interval", false,
                (p0) => messageExpiryInterval = p0),
            StringNullableFormField(
                "response topic", false, (p0) => responseTopic = p0),
            StringOrBytesNullableFormField(
                "correlation data", false, (p0) => correlationData = p0),
            StringNullableFormField(
                "content type", false, (p0) => contentType = p0),
          ]),
          FilledButton(
              onPressed: onPublishPressed, child: const Text("Publish"))
        ]));
  }
}
