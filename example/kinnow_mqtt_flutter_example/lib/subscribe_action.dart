import 'package:flutter/material.dart';
import 'package:kinnow_mqtt/kinnow_mqtt.dart';
import 'package:kinnow_mqtt_flutter_example/logs_provider.dart';
import 'package:kinnow_mqtt_flutter_example/mqtt_action_selector.dart';
import 'package:kinnow_mqtt_flutter_example/mqtt_logs.dart';
import 'package:kinnow_mqtt_flutter_example/mqtt_provider.dart';

class TopicSubscriptionData {
  String? topic;
  MqttQos? maxQos;
  bool noLocal = false;
  bool retainAsPublished = false;
  RetainHandlingOption? retainHandling;
}

class SubscribeAction extends StatefulWidget {
  const SubscribeAction({super.key});

  @override
  State<SubscribeAction> createState() => _SubscribeActionState();
}

class _SubscribeActionState extends State<SubscribeAction>
    with AutomaticKeepAliveClientMixin {
  final List<TopicSubscriptionData> topicSubData = [];
  final panelExpanded = <bool>[];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int? subscriptionId;

  void onSubscribePressed() {
    // LogsProvider.of(context).addLog(SubscribePacketLog(
    //     SubscribePacket(
    //         [TopicSubscription("ogga booga test", MqttQos.exactlyOnce)]),
    //     Future.delayed(
    //       const Duration(seconds: 10),
    //       () => SubackPacket(
    //           69, [SubackReasonCode.grantedQoS2], null, const {}),
    //     )));
    // return;

    if (_formKey.currentState!.validate() == false) {
      return;
    }
    _formKey.currentState!.save();

    final subPkt = SubscribePacket(
      topicSubData.map((e) => TopicSubscription(
            e.topic!,
            e.maxQos!,
            retainHandling: e.retainHandling!,
            noLocal: e.noLocal,
            retainAsPublished: e.retainAsPublished,
          )),
      subscriptionId: subscriptionId,
    );

    final subAckFut = MqttProvider.of(context).client!.subscribe(subPkt);
    LogsProvider.of(context).addLog(SubscribePacketLog(subPkt, subAckFut));
  }

  ExpansionPanel _buildTopicSubscriptionForm((int, TopicSubscriptionData) e) {
    return ExpansionPanel(
        isExpanded: panelExpanded[e.$1],
        canTapOnHeader: true,
        headerBuilder: (context, isExpanded) => Align(
            alignment: Alignment.centerLeft, child: Text("Topic ${e.$1}")),
        body: Column(children: [
          StringNullableFormField(
              "topic", true, (p0) => topicSubData[e.$1].topic = p0),
          EnumFormField("max qos", true, MqttQos.values.asNameMap(),
              (p0) => topicSubData[e.$1].maxQos = p0),
          EnumFormField(
              "retain handling",
              true,
              RetainHandlingOption.values.asNameMap(),
              (p0) => topicSubData[e.$1].retainHandling = p0),
          BoolFormField(
              "loop back",
              !topicSubData[e.$1].noLocal,
              (p0) => setState(() {
                    topicSubData[e.$1].noLocal = !p0;
                  })),
          BoolFormField(
              "always show retain",
              topicSubData[e.$1].retainAsPublished,
              (p0) => setState(() {
                    topicSubData[e.$1].retainAsPublished = p0;
                  })),
        ]));
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
      child: Column(
        children: [
          const SizedBox(height: 10),
          InfoButton(infoBuilder: infoBuilder),
          ExpansionPanelList(
            children: topicSubData.indexed
                .map((e) => _buildTopicSubscriptionForm(e))
                .toList(),
            expansionCallback: (panelIndex, isExpanded) => setState(() {
              panelExpanded[panelIndex] = isExpanded;
            }),
          ),
          IntNullableFormField(
              "subscription id", false, (p0) => subscriptionId = p0),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton(
                  onPressed: () => setState(() {
                        topicSubData.add(TopicSubscriptionData());
                        for (int i = 0; i < panelExpanded.length; i++) {
                          panelExpanded[i] = false;
                        }
                        panelExpanded.add(true);
                      }),
                  child: const Icon(Icons.add)),
              FilledButton(
                  onPressed: () => setState(() {
                        topicSubData.removeLast();
                        panelExpanded.removeLast();
                      }),
                  child: const Icon(Icons.delete)),
              FilledButton(
                  onPressed: (topicSubData.isEmpty) ? null : onSubscribePressed,
                  child: const Text("Subscribe")),
            ],
          ),
        ],
      ),
    );
  }

  Widget infoBuilder(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Subscribing", style: titleStyle),
      const Text(
          "MQTT actually allows subscribing to multiple topics at the same time, Use the '+' and 'trashcan' icons to add or remove topics"),
      Text("Topic", style: titleStyle),
      const Text(
          "The topic to subscribe to. Can contain wildcards like '#' and '+'"),
      Text("Max QoS", style: titleStyle),
      const Text(
          "This is the Maximum QoS with which the broker will send messages to this client on this topic. Keep in mind that this is the QoS between the broker and the client irrespective of the sender. Higher QoS messages are downgraded by the broker to maxQoS. For eg. if you subscribe to a topic 'test' with MaxQos = QoS1, and some client sends a message with QoS2. That message will be received with QoS1. QoS1 and QoS0 messages will be received with their original QoS"),
      Text("Retain Handling", style: titleStyle),
      const Text(
          "Configures how to handle retained messages.'sendRetainedOnEachMatchSub' sends the retained messages even if this is the second time subscribing to the topic. 'sendRetainedOnFirstMatchSub' means do not send retained messages if the topic was subscribed earlier. 'doNotSendRetainedMessages' will never send retained messages"),
      Text("Loop back", style: titleStyle),
      const Text(
          "Configures whether the subscription should also send back the client's own messages"),
      Text("Always Show Retain", style: titleStyle),
      const Text(
          "if set to `true` all retained messages will have the retain flag set to true, if `false` only the message that was retained before subscription will have the retain flag set"),
      Text("Subscription Id", style: titleStyle),
      const Text(
          "Messages sent to the client due to this subscription will have the specified subscription along with them. This can be useful to assign callbacks without comparing string for performance"),
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}
