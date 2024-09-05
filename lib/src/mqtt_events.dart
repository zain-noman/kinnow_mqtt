import 'package:cutie_mqtt/src/conn_ack_packet.dart';

sealed class MqttEvent {}

class SocketConnectionFailure extends MqttEvent {}

class SocketEnded extends MqttEvent {}

class MalformedPacket extends MqttEvent {
  final List<int> packetBytes;
  final String? message;

  MalformedPacket(this.packetBytes, {this.message});
}

class ConnAckEvent extends MqttEvent{
  ConnAckPacket connAck;
  ConnAckEvent(this.connAck);
}