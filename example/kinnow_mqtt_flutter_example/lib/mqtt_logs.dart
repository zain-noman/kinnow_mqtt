import "package:flutter/material.dart";
import "package:kinnow_mqtt/kinnow_mqtt.dart";
import "package:kinnow_mqtt_flutter_desktop_client/logs_provider.dart";
import "package:hex/hex.dart";

sealed class MqttEventLog {
  final bool isSentByClient;

  MqttEventLog({required this.isSentByClient});
}

class KeyValueRow extends StatelessWidget {
  final String keyText;
  final String value;

  const KeyValueRow({super.key, required this.keyText, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$keyText: ", style: Theme.of(context).textTheme.labelLarge),
        Flexible(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
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
        Text(log.title, style: Theme.of(context).textTheme.titleMedium),
        if (log.subtitle != null)
          Flexible(
            child: Text(log.subtitle!,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        const SizedBox(height: 10),
        ...log.data.entries
            .map((e) => KeyValueRow(keyText: e.key, value: e.value))
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

    final labelStyle = Theme.of(context).textTheme.labelLarge;
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    final onSecondaryLabelStyle = Theme.of(context).textTheme.labelLarge;

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
            style: Theme.of(context).textTheme.titleMedium),
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
              .map((e) => KeyValueRow(keyText: e.key, value: e.value))
              .toList(),
        )
      ],
    );
  }
}

class ResponseFutureBuilder<T> extends StatelessWidget {
  const ResponseFutureBuilder(
      {super.key,
      required this.future,
      required this.responseCompletedBuilder,
      this.awaitingFutureText = "Awaiting Response"});

  final String awaitingFutureText;
  final Future<T> future;
  final Widget Function(T response) responseCompletedBuilder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          final labelStyle = Theme.of(context).textTheme.labelLarge;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Row(
              children: [
                Text(awaitingFutureText, style: labelStyle),
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
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Subscribe Packet",
            style: Theme.of(context).textTheme.titleMedium),
        if (subscribePacket.subscriptionId != null)
          KeyValueRow(
              keyText: "Subscription Id",
              value: subscribePacket.subscriptionId.toString()),
        ...subscribePacket.topics.indexed.map(
            (e) => KeyValueRow(keyText: "Topic ${e.$1}", value: e.$2.topic)),
        Divider(color: Theme.of(context).colorScheme.shadow),
        ResponseFutureBuilder(
          future: subackFut,
          responseCompletedBuilder: (response) {
            if (response == null) {
              return Text("Subscribe Failed", style: labelStyle);
            }
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Subscribe Acknowledge Packet",
                      style: Theme.of(context).textTheme.titleMedium),
                  ...response.reasonCodes.indexed.map((e) =>
                      KeyValueRow(keyText: "Topic ${e.$1}", value: e.$2.name)),
                  if (response.reasonString != null)
                    KeyValueRow(
                        keyText: "reason string", value: response.reasonString!)
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

    final labelStyle = Theme.of(context).textTheme.labelLarge;
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    final onSecondaryLabelStyle = Theme.of(context).textTheme.labelLarge;

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Publish", style: Theme.of(context).textTheme.titleMedium),
        Row(children: [
          Text("Topic: ", style: labelStyle),
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
              .map((e) => KeyValueRow(keyText: e.key, value: e.value))
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
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TxPublishPktLogWidget(pkt: log.pkt, qos: MqttQos.atMostOnce),
        Divider(color: Theme.of(context).colorScheme.shadow),
        ResponseFutureBuilder(
          future: log.response,
          awaitingFutureText: "Sending",
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        KeyValueRow(keyText: "packet id", value: packetId.toString()),
        if (reasonCode != null)
          KeyValueRow(keyText: "reason code", value: reasonCode!),
        if (reasonString != null)
          KeyValueRow(keyText: "reason string", value: reasonString!),
      ],
    );
  }
}

class Qos1PublishLogWidget extends StatelessWidget {
  final TxPublishPacketLogQos1 log;

  const Qos1PublishLogWidget({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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

class UnsubscribeMqttEventLog extends MqttEventLog {
  final UnsubscribePacket unsubscribePacket;
  final Future<UnsubackPacket?> unsubackFut;

  UnsubscribeMqttEventLog(this.unsubscribePacket, this.unsubackFut,
      {super.isSentByClient = true});
}

class UnsubscribeLogWidget extends StatelessWidget {
  final UnsubscribeMqttEventLog log;

  const UnsubscribeLogWidget({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Unsubscribe Packet",
            style: Theme.of(context).textTheme.titleMedium),
        ...log.unsubscribePacket.topicFilters.indexed
            .map((e) => KeyValueRow(keyText: "Topic ${e.$1}", value: e.$2)),
        Divider(color: Theme.of(context).colorScheme.shadow),
        ResponseFutureBuilder(
            future: log.unsubackFut,
            responseCompletedBuilder: (response) {
              if (response == null) {
                return Text("Acknowledge not received", style: labelStyle);
              }
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Unsubscribe Acknowledge Packet",
                        style: Theme.of(context).textTheme.titleMedium),
                    ...response.reasonCodes.indexed.map((e) => KeyValueRow(
                        keyText: "Topic ${e.$1}", value: e.$2.name)),
                    if (response.reasonString != null)
                      KeyValueRow(
                          keyText: "reason string",
                          value: response.reasonString!)
                  ]);
            })
      ],
    );
  }
}
