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

class ResponseFutureBuilder<T> extends StatelessWidget {
  const ResponseFutureBuilder({
    super.key,
    required this.future,
    required this.responseCompletedBuilder,
  });

  final Future<T> future;
  final Widget Function(T response) responseCompletedBuilder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              );
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Row(
              children: [
                Text("Awaiting Response", style: labelStyle),
                const Spacer(),
                const CircularProgressIndicator()
              ],
            );
          }
          return responseCompletedBuilder(snapshot.data as T);
        });
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
        ResponseFutureBuilder(
          future: subackFut,
          responseCompletedBuilder: (response) {
            if (response == null) {
              return Text("Subscribe Failed", style: labelStyle);
            }
            return Column(children: [
              Text("Subscribe Acknowledge Packet",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      )),
              ...response.reasonCodes.indexed.map((e) => Row(children: [
                    Text("Topic ${e.$1}: ", style: labelStyle),
                    Text(e.$2.name, style: bodyStyle)
                  ])),
              if (response.reasonString != null)
                Row(children: [
                  Text("reason string: ", style: labelStyle),
                  Text(response.reasonString!, style: bodyStyle)
                ])
            ]);
          },
        ),
      ],
    );
  }
}

class TxPublishPacketLogQos0 extends MqttEventLog {
  final TxPublishPacket pkt;
  final Future<bool> response;

  TxPublishPacketLogQos0(this.pkt, this.response,
      {super.isSentByClient = true});
}

class TxPublishPacketLogQos1 extends MqttEventLog {
  final TxPublishPacket pkt;
  final Future<PubackPacket?> response;

  TxPublishPacketLogQos1(this.pkt, this.response,
      {super.isSentByClient = true});
}

class TxPublishPacketLogQos2 extends MqttEventLog {
  final TxPublishPacket pkt;
  final Future<(PubrecPacket, PubcompPacket)?> response;

  TxPublishPacketLogQos2(this.pkt, this.response,
      {super.isSentByClient = true});
}

class TxPublishPktLogWidget extends StatelessWidget {
  final TxPublishPacket pkt;
  final MqttQos qos;

  const TxPublishPktLogWidget(
      {super.key, required this.pkt, required this.qos});

  @override
  Widget build(BuildContext context) {
    final String payloadDisplay;
    if (LogsDisplayFormatProvider.of(context).showLogsInHex) {
      payloadDisplay = HEX.encode(pkt.payload.asBytes);
    } else {
      payloadDisplay = pkt.payload.asString;
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
      "Payload Format": pkt.payloadFormat.toString(),
      "Message Expiry Interval": pkt.messageExpiryInterval.toString(),
      "Response Topic": pkt.responseTopic.toString(),
      "Correlation Data": (pkt.correlationData == null)
          ? "null"
          : HEX.encode(pkt.correlationData!),
      "Content Type": pkt.contentType.toString(),
      "Alias Used": pkt.useAlias.toString(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Publish",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                )),
        Row(children: [
          Flexible(
            child: Text("Topic: ", style: labelStyle),
          ),
          Text(pkt.topic, style: bodyStyle),
          const Spacer(),
          if (pkt.retain) Text("Retained", style: onSecondaryLabelStyle),
          const SizedBox(width: 10),
          Text("Qos${qos.index}", style: onSecondaryLabelStyle),
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

class Qos0PublishLogWidget extends StatelessWidget {
  final TxPublishPacketLogQos0 log;

  const Qos0PublishLogWidget({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        );
    return Column(
      children: [
        TxPublishPktLogWidget(pkt: log.pkt, qos: MqttQos.atMostOnce),
        Divider(color: Theme.of(context).colorScheme.shadow),
        ResponseFutureBuilder(
          future: log.response,
          responseCompletedBuilder: (response) {
            if (response) {
              return Text("Sent Successfully", style: labelStyle);
            } else {
              return Text("Failed To Send", style: labelStyle);
            }
          },
        )
      ],
    );
  }
}

// used for puback, pubrec, pubcomp
class PubCommonLogWidget extends StatelessWidget {
  final String title;
  final int packetId;
  final String? reasonCode;
  final String? reasonString;

  const PubCommonLogWidget({
    super.key,
    required this.title,
    required this.packetId,
    this.reasonCode,
    this.reasonString,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer);
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                )),
        Row(children: [
          Text("packet id: ", style: labelStyle),
          Text(packetId.toString(), style: bodyStyle)
        ]),
        if (reasonCode != null)
          Row(children: [
            Text("reason code: ", style: labelStyle),
            Text(reasonCode!, style: bodyStyle)
          ]),
        if (reasonString != null)
          Row(children: [
            Text("reason string: ", style: labelStyle),
            Text(reasonString!, style: bodyStyle)
          ]),
      ],
    );
  }
}

class Qos1PublishLogWidget extends StatelessWidget {
  final TxPublishPacketLogQos1 log;

  const Qos1PublishLogWidget({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer);
    return Column(
      children: [
        TxPublishPktLogWidget(pkt: log.pkt, qos: MqttQos.atLeastOnce),
        Divider(color: Theme.of(context).colorScheme.shadow),
        ResponseFutureBuilder(
          future: log.response,
          responseCompletedBuilder: (response) {
            if (response == null) {
              return Text("Acknowledge not received", style: labelStyle);
            }
            return PubCommonLogWidget(
              title: "Pub Ack",
              packetId: response.packetId,
              reasonCode: response.reasonCode?.name,
              reasonString: response.reasonString,
            );
          },
        )
      ],
    );
  }
}

class Qos2PublishLogWidget extends StatelessWidget {
  final TxPublishPacketLogQos2 log;

  const Qos2PublishLogWidget({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer);
    return Column(
      children: [
        TxPublishPktLogWidget(pkt: log.pkt, qos: MqttQos.exactlyOnce),
        Divider(color: Theme.of(context).colorScheme.shadow),
        ResponseFutureBuilder(
          future: log.response,
          responseCompletedBuilder: (response) {
            if (response == null) {
              return Text("Acknowledge not received", style: labelStyle);
            }
            return Column(
              children: [
                PubCommonLogWidget(
                  title: "Pub Rec",
                  packetId: response.$1.packetId,
                  reasonCode: response.$1.reasonCode?.name,
                  reasonString: response.$1.reasonString,
                ),
                PubCommonLogWidget(
                  title: "Pub Comp",
                  packetId: response.$2.packetId,
                  reasonCode: response.$2.reasonCode?.name,
                  reasonString: response.$2.reasonString,
                ),
              ],
            );
          },
        )
      ],
    );
  }
}
