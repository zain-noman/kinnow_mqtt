import 'package:cutie_mqtt/src/conn_ack_packet.dart';

sealed class MqttEvent {}

class NetworkConnectionFailure extends MqttEvent {}

class NetworkEnded extends MqttEvent {}

class MalformedPacket extends MqttEvent {
  final List<int> packetBytes;
  final String? message;

  MalformedPacket(this.packetBytes, {this.message});
}

class ConnAckEvent extends MqttEvent {
  ConnAckPacket connAck;

  ConnAckEvent(this.connAck);
}

class PingReqSent extends MqttEvent {
  late DateTime sentAt;

  PingReqSent({DateTime? sentTime}) {
    sentAt = sentTime ?? DateTime.now();
  }
}

class PingRespReceived extends MqttEvent {
  late DateTime receivedAt;

  PingRespReceived({DateTime? recvTime}) {
    receivedAt = recvTime ?? DateTime.now();
  }
}

class PingRespNotReceived extends MqttEvent {}

class ConnackTimedOut extends MqttEvent {}