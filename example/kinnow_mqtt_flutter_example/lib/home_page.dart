import 'package:flutter/material.dart';
import 'logs_view.dart';
import 'mqtt_action_selector.dart';
import 'mqtt_provider.dart';

class HomePage extends StatelessWidget {
  final Widget logsWidget;
  final Widget actionsWidget;

  const HomePage(
      {super.key,
      this.logsWidget = const LogsView(),
      this.actionsWidget = const ActionSelector()});

  @override
  Widget build(BuildContext context) {
    Widget connectionIcon;
    if (MqttProvider.of(context).client == null) {
      connectionIcon = Icon(
        Icons.cloud_off,
        color: Theme.of(context).colorScheme.onPrimary,
      );
    } else {
      connectionIcon = StreamBuilder(
        stream: MqttProvider.of(context).client!.connectionStatusStream,
        builder: (context, snapshot) {
          // no update has been provided, use [client.isConnected]
          bool connected;
          if (!snapshot.hasData) {
            connected = MqttProvider.of(context).client!.isConnected;
          } else {
            connected = snapshot.data!;
          }
          return (connected)
              ? connectionIcon = Icon(Icons.cloud_done_outlined,
                  color: Theme.of(context).colorScheme.onPrimary)
              : connectionIcon = Icon(Icons.cloud_off,
                  color: Theme.of(context).colorScheme.onPrimary);
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Kinnow MQTT",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        actions: [connectionIcon],
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: OrientationBuilder(builder: (context, orientation) {
        final children = [
          Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: logsWidget,
              )),
          if (orientation == Orientation.portrait)
            Divider(
                color: Theme.of(context).colorScheme.shadow),
          if (orientation == Orientation.landscape)
            VerticalDivider(
                color: Theme.of(context).colorScheme.shadow),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: actionsWidget,
            ),
          ),
        ];
        if (orientation == Orientation.portrait) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children);
        } else {
          return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children);
        }
      }),
    );
  }
}
