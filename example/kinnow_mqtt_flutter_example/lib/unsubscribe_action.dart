import 'package:flutter/material.dart';
import 'package:kinnow_mqtt/kinnow_mqtt.dart';
import 'package:kinnow_mqtt_flutter_example/mqtt_action_selector.dart';
import 'package:kinnow_mqtt_flutter_example/mqtt_logs.dart';

import 'logs_provider.dart';
import 'mqtt_provider.dart';

class UnsubscribeAction extends StatefulWidget {
  const UnsubscribeAction({super.key});

  @override
  State<UnsubscribeAction> createState() => _UnsubscribeActionState();
}

class _UnsubscribeActionState extends State<UnsubscribeAction>
    with AutomaticKeepAliveClientMixin {
  final topics = <String?>[];
  final _formKey = GlobalKey<FormState>();

  void onUnsubscribePressed() {
    if (_formKey.currentState!.validate() == false) {
      return;
    }
    _formKey.currentState!.save();

    final unsubPkt = UnsubscribePacket(topics.nonNulls.toList());

    final unSubAckFut = MqttProvider.of(context).client!.unsubscribe(unsubPkt);
    LogsProvider.of(context)
        .addLog(UnsubscribeMqttEventLog(unsubPkt, unSubAckFut));
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
          ...topics.indexed.map((e) => StringNullableFormField(
              "Topic ${e.$1}", true, (p0) => topics[e.$1] = p0)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton(
                  onPressed: () => setState(() => topics.add(null)),
                  child: const Icon(Icons.add)),
              FilledButton(
                  onPressed: () => setState(() => topics.removeLast()),
                  child: const Icon(Icons.delete)),
              FilledButton(
                  onPressed: (topics.isEmpty) ? null : onUnsubscribePressed,
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
      Text("Unsubscribing", style: titleStyle),
      const Text(
          "Similarly to subscribing, you can unsubscribe from multiple topics at the same time"),
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}
