import "package:flutter/material.dart";
import "package:kinnow_mqtt/kinnow_mqtt.dart";
import "package:kinnow_mqtt_flutter_example/logs_provider.dart";
import "package:hex/hex.dart";

sealed class MqttEventLog {
  final bool isSentByClient;

  MqttEventLog({required this.isSentByClient});
}

class GenericMqttEventLog extends MqttEventLog {
  final String title;
  final String? subtitle;
  final Map<String, String> data;

  GenericMqttEventLog(
      {required super.isSentByClient,
      required this.title,
      this.subtitle,
      this.data = const {}});
}

class GenericMqttLogWidget extends StatelessWidget {
  final GenericMqttEventLog log;

  const GenericMqttLogWidget(this.log, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          log.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
        if (log.subtitle != null)
          Flexible(
            child: Text(
              log.subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
        const SizedBox(height: 10),
        ...log.data.entries.map((e) => Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${e.key}: ",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                Flexible(
                  child: Text(
                    e.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                )
              ],
            ))
      ],
    );
  }
}

class RxPublishPacketLog extends MqttEventLog {
  final RxPublishPacket packet;

  RxPublishPacketLog(this.packet, {super.isSentByClient = false});
}

class RxPublishPacketLogWidget extends StatelessWidget {
  final RxPublishPacketLog log;

  const RxPublishPacketLogWidget({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final String payloadDisplay;
    if (LogsDisplayFormatProvider.of(context).showLogsInHex) {
      payloadDisplay = HEX.encode(log.packet.payload.asBytes);
    } else {
      payloadDisplay = log.packet.payload.asString;
    }

    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        );
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        );
    final onSecondaryLabelStyle =
        Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            );

    final Map<String, String> additionalData = {
      "Payload Format": log.packet.payloadFormat.toString(),
      "Message Expiry Interval": log.packet.messageExpiryInterval.toString(),
      "Content Type": log.packet.contentType.toString(),
      "Alias Used": log.packet.aliasUsed.toString(),
      "Subscription Id": log.packet.subscriptionId.toString(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Message Received",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                )),
        Row(children: [
          Flexible(
            child: Text("Topic: ", style: labelStyle),
          ),
          Text(log.packet.topic, style: bodyStyle),
          const Spacer(),
          if (log.packet.retain) Text("Retained", style: onSecondaryLabelStyle),
          const SizedBox(width: 10),
          Text("Qos${log.packet.qos.index}", style: onSecondaryLabelStyle),
        ]),
        Text("Payload", style: labelStyle),
        Text(payloadDisplay, style: bodyStyle),
        ExpansionTile(
          title: Text("More", style: labelStyle),
          children: additionalData.entries
              .map((e) => Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${e.key}: ", style: labelStyle),
                      Flexible(child: Text(e.value, style: bodyStyle))
                    ],
                  ))
              .toList(),
        )
      ],
    );
  }
}

class SubscribePacketLog extends MqttEventLog {
  final SubscribePacket subscribePacket;
  final Future<SubackPacket?> subackFut;

  SubscribePacketLog(this.subscribePacket, this.subackFut,
      {super.isSentByClient = true});
}

class SubscribePacketLogWidget extends StatelessWidget {
  final SubscribePacket subscribePacket;
  final Future<SubackPacket?> subackFut;

  const SubscribePacketLogWidget(
      {super.key, required this.subscribePacket, required this.subackFut});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        );
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Subscribe Packet",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                )),
        if (subscribePacket.subscriptionId != null)
          Row(children: [
            Text("Subscription Id: ", style: labelStyle),
            Text(subscribePacket.subscriptionId.toString(), style: bodyStyle),
          ]),
        ...subscribePacket.topics.indexed.map(
          (e) => Row(children: [
            Text("Topic ${e.$1}: ", style: labelStyle),
            Text(e.$2.topic, style: bodyStyle),
          ]),
        ),
        Divider(color: Theme.of(context).colorScheme.shadow),
        FutureBuilder(
          future: subackFut,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Row(
                children: [
                  Text("Awaiting Response", style: labelStyle),
                  const Spacer(),
                  const CircularProgressIndicator()
                ],
              );
            }
            if (snapshot.data == null) {
              return Text("Subscribe failed", style: labelStyle);
            }
            final subAck = snapshot.data!;
            return Column(children: [
              Text("Subscribe Acknowledge Packet",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      )),
              ...subAck.reasonCodes.indexed.map((e) => Row(children: [
                    Text("Topic ${e.$1}: ", style: labelStyle),
                    Text(e.$2.name, style: bodyStyle)
                  ])),
              if (subAck.reasonString != null)
                Row(children: [
                  Text("reason string: ", style: labelStyle),
                  Text(subAck.reasonString!, style: bodyStyle)
                ])
            ]);
          },
        )
      ],
    );
  }
}
