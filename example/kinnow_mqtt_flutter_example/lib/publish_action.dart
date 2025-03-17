import "package:flutter/material.dart";
import "package:kinnow_mqtt/kinnow_mqtt.dart";
import "package:kinnow_mqtt_flutter_desktop_client/logs_provider.dart";
import "package:kinnow_mqtt_flutter_desktop_client/mqtt_action_selector.dart";
import "package:kinnow_mqtt_flutter_desktop_client/mqtt_logs.dart";
import "package:kinnow_mqtt_flutter_desktop_client/mqtt_provider.dart";

class PublishAction extends StatefulWidget {
  const PublishAction({super.key});

  @override
  State<PublishAction> createState() => _PublishActionState();
}

class _PublishActionState extends State<PublishAction>
    with AutomaticKeepAliveClientMixin {
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
      (payload == null) ? StringOrBytes.fromBytes([]) : payload!,
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
    super.build(context);
    if (MqttProvider.of(context).client == null ||
        MqttProvider.of(context).client!.isRunning() == false) {
      return Center(
        child: Text("Client is not started",
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
      );
    }
    return Form(
        key: _formKey,
        child: Column(children: [
          const SizedBox(height: 10),
          InfoButton(infoBuilder: buildInfo),
          StringNullableFormField("topic", true, (p0) => topic = p0),
          StringOrBytesNullableFormField(
              "payload", false, (p0) => payload = p0),
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
          const SizedBox(height: 10),
          FilledButton(
              onPressed: onPublishPressed, child: const Text("Publish"))
        ]));
  }

  Widget buildInfo(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Topic", style: titleStyle),
      const Text(
          "Every client that is 'subscribed' to this topic will receive the sent message"),
      Text("Payload", style: titleStyle),
      const Text(
          "The data of the message. The user can choose what format he wants to enter the data in. 'Hex' is for hexadecimal and 'Ascii' is for text. The data sent is always in binary ultimately the options are provided only for convenience and have no impact on the messages data"),
      Text("Retain", style: titleStyle),
      const Text(
          "if set the message is 'saved' by the broker. Whenever a client 'subscribes' to corresponding topic, it can receive the stored message regardless of when it was sent. Please note that only one message is retained per topic, if another retained message is sent on the topic, the broker will save this new message instead and discard the old one. To remove a retained message, send a retained message with an empty payload"),
      Text("QoS", style: titleStyle),
      const Text(
          "There are Three QoS levels. When Set to 'atMostOnce'(QoS0) Kinnow Mqtt will ensure that it sends the message but there is no guarantee of whether it was received (This can happen because it is hard to determine whether a connection is actually alive or not). When set to 'atLeastOnce'(QoS1), the broker will respond with an acknowledge message ensuring that the message is received. A situation may occur where a QoS1 message was received but the connection broke before the client could receive an acknowledgement, the client will then retry sending the packet and eventually get an acknowledgement. this can lead to copies of the message being sent. When set to 'exactlyOnce'(QoS2), the client fist sends a packet, the broker responds with an acknowledgement, the client then tells the broker that the transmission of this packet is completed, finally the broker acknowledges this packet too. Only at this point does the broker forward the message to other clients"),
      Text("Use Alias", style: titleStyle),
      const Text(
          "This feature allows reducing the packet size when sending multiple packets to the same topic. When a message is sent to a topic for the first time, the client will create an id corresponding to a topic and send it along with the message. In subsequent messages, the topic will be used instead on the topic reducing packet size"),
      Text("Payload Format", style: titleStyle),
      const Text(
          "This feature can be used to inform receivers if the payload's format"),
      Text("Message Expiry Interval", style: titleStyle),
      const Text(
          "Is used by the broker to delete time-sensitive messages, value is in seconds"),
      Text("Response Topic", style: titleStyle),
      const Text(
          "MQTT 5 has a request response feature, in a publish packet you can specify where you expect the reply"),
      Text("Correlation Data", style: titleStyle),
      const Text(
          "This is used in conjunction with the response topic. It can contain any data, like a message Id so you can be sure that the response was in reply to this specific request"),
      Text("Content Type", style: titleStyle),
      const Text(
          "A string representation of the type of content in the payload"),
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}
