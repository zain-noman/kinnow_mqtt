import 'package:flutter/material.dart';
import 'package:kinnow_mqtt/kinnow_mqtt.dart';
import 'package:kinnow_mqtt_flutter_example/mqtt_action_selector.dart';
import 'package:kinnow_mqtt_flutter_example/mqtt_provider.dart';

class DisconnectAction extends StatefulWidget {
  const DisconnectAction({super.key});

  @override
  State<DisconnectAction> createState() => _DisconnectActionState();
}

class _DisconnectActionState extends State<DisconnectAction>
    with AutomaticKeepAliveClientMixin {
  DisconnectReasonCode? reasonCode;
  int? sessionExpiryInterval;
  String? reasonString;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
            InfoButton(infoBuilder: buildInfo),
            EnumFormField(
                "reason",
                true,
                DisconnectReasonCode.values.asNameMap(),
                (p0) => reasonCode = p0),
            IntNullableFormField("session expiry interval", false,
                (p0) => sessionExpiryInterval = p0),
            StringNullableFormField(
                "reason string", false, (p0) => reasonString = p0),
            const SizedBox(height: 10),
            FilledButton(onPressed: onPressed, child: const Text("disconnect"))
          ],
        ));
  }

  Widget buildInfo(BuildContext context){
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    return Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
      Text("Reason", style: titleStyle),
      const Text("Is used to describe the reason for disconnection"),
      Text("Session expiry interval", style: titleStyle),
      const Text("The mqtt broker will delete session state after this period (in seconds) if provided"),
      Text("Reason String", style: titleStyle),
      const Text("A human readable string to provide extra information about the reason of disconnection"),
    ]);
  }

  void onPressed() {
    if (_formKey.currentState!.validate() == false) {
      return;
    }
    _formKey.currentState!.save();

    final disconnectPkt = DisconnectPacket(reasonCode!,
        sessionExpiryInterval: sessionExpiryInterval,
        reasonString: reasonString);

    MqttProvider.of(context).client!.disconnect(disconnectPkt: disconnectPkt);
  }

  @override
  bool get wantKeepAlive => true;
}
