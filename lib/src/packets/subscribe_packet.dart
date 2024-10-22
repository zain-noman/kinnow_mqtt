import '../byte_utils.dart';
import '../mqtt_fixed_header.dart';
import '../mqtt_packet_types.dart';
import '../mqtt_qos.dart';

/// How to handle retained messages
enum RetainHandlingOption {
  /// send the retained messages even if this is the second time subscribing to the topic
  sendRetainedOnEachMatchSub,

  /// do not send retained messages if the topic was subscribed earlier
  sendRetainedOnFirstMatchSub,

  /// do Not Send Retained Messages
  doNotSendRetainedMessages
}

/// The subscription properties for a single topic
class TopicSubscription {
  /// the topic of the subscription
  final String topic;

  /// if set to QoS1 or QoS 0, the server will downgrade any higher QoS messages
  /// to the QoS set here
  final MqttQos maxQos;

  /// if set to `true` messages sent by the user will not be looped back
  final bool noLocal;

  /// if set to `true` all retained messages will have the [RxPublishPacket.retain]
  /// flag set to true, if `false` only the message that was retained
  /// before subscription will have the retain flag set
  final bool retainAsPublished;

  /// whether to receive retained messages
  final RetainHandlingOption retainHandling;

  /// Crate subscription for a topic
  TopicSubscription(
    this.topic,
    this.maxQos, {
    this.noLocal = false,
    this.retainAsPublished = false,
    this.retainHandling = RetainHandlingOption.sendRetainedOnEachMatchSub,
  });
}

/// Packet sent by client to subscribe to one or more topics
class SubscribePacket {
  /// custom properties
  final Map<String, String> userProperties;

  /// the topics along with properties for subscription
  final Iterable<TopicSubscription> topics;

  /// If set, messages received due to this subscription will have
  /// [RxPublishPacket.subscriptionId] set to the same id
  final int? subscriptionId;

  SubscribePacket(this.topics,
      {this.subscriptionId, this.userProperties = const {}});
}

class InternalSubscribePacket {
  final int packetId;
  final SubscribePacket subData;

  InternalSubscribePacket(this.packetId, this.subData);

  List<int> toBytes() {
    final body = <int>[packetId >> 8, packetId & 0xFF];
    final props = <int>[];
    if (subData.subscriptionId != null) {
      props.add(0x0B);
      props.addAll(ByteUtils.makeVariableByteInteger(subData.subscriptionId!));
    }
    ByteUtils.appendStringPairProperty(subData.userProperties, 0x26, props);
    body.addAll(ByteUtils.makeVariableByteInteger(props.length));
    body.addAll(props);
    for (final topic in subData.topics) {
      int subOptions = 0;
      subOptions |= topic.maxQos.index;
      if (topic.noLocal) subOptions |= 1 << 2;
      if (topic.retainAsPublished) subOptions |= 1 << 3;
      subOptions |= topic.retainHandling.index << 4;

      body.addAll(ByteUtils.makeUtf8StringBytes(topic.topic));
      body.add(subOptions);
    }
    return [
      ...MqttFixedHeader(MqttPacketType.subscribe, 0x02, body.length).toBytes(),
      ...body
    ];
  }
}
