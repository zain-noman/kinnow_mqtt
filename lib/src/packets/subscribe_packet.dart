import 'package:cutie_mqtt/src/byte_utils.dart';
import 'package:cutie_mqtt/src/mqtt_fixed_header.dart';
import 'package:cutie_mqtt/src/mqtt_packet_types.dart';
import 'package:cutie_mqtt/src/mqtt_qos.dart';

enum RetainHandlingOption {
  sendRetainedOnEachMatchSub,
  sendRetainedOnFirstMatchSub,
  donNotSendRetainedMessages
}

class TopicSubscription {
  final String topic;
  final MqttQos maxQos;
  final bool noLocal;
  final bool retainAsPublished;
  final RetainHandlingOption retainHandling;

  TopicSubscription(
    this.topic,
    this.maxQos, {
    this.noLocal = false,
    this.retainAsPublished = false,
    this.retainHandling = RetainHandlingOption.sendRetainedOnEachMatchSub,
  });
}

class SubscribePacket {
  final Map<String, String> userProperties;
  final Iterable<TopicSubscription> topics;
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
