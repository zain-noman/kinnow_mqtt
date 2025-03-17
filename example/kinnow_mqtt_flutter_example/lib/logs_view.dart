import 'package:flutter/material.dart';
import 'package:kinnow_mqtt_flutter_desktop_client/mqtt_logs.dart';
import 'logs_provider.dart';

class LogsView extends StatelessWidget {
  const LogsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: LogsProvider.of(context).logs.length,
      itemBuilder: (context, index) {
        final log = LogsProvider.of(context).logs.elementAt(index);

        final Widget dataWidget;

        // since the MqttEventLog is a sealed class i can switch case over its
        // subtypes
        switch (log) {
          case GenericMqttEventLog():
            dataWidget = GenericMqttLogWidget(log);
          case RxPublishPacketLog():
            dataWidget = RxPublishPacketLogWidget(log: log);
          case SubscribePacketLog():
            dataWidget = SubscribePacketLogWidget(
                subscribePacket: log.subscribePacket, subackFut: log.subackFut);
          case TxPublishPacketLogQos0():
            dataWidget = Qos0PublishLogWidget(log: log);
          case TxPublishPacketLogQos1():
            dataWidget = Qos1PublishLogWidget(log: log);
          case TxPublishPacketLogQos2():
            dataWidget = Qos2PublishLogWidget(log: log);
          case UnsubscribeMqttEventLog():
            dataWidget = UnsubscribeLogWidget(log: log);
        }

        return Align(
          alignment:
              log.isSentByClient ? Alignment.centerRight : Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.75,
            child: Container(
              // color: Theme.of(context).colorScheme.primary,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Theme(
                  data: Theme.of(context).copyWith(
                      textTheme: Theme.of(context).textTheme.apply(
                          bodyColor: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer)),
                  child: dataWidget,
                ),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const SizedBox(
        height: 10,
      ),
    );
  }
}
