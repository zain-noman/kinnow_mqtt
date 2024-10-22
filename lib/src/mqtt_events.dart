import 'package:kinnow_mqtt/kinnow_mqtt.dart';

import 'packets/conn_ack_packet.dart';
import 'packets/disconnect_packet.dart';

/// A base class for all Mqtt Events.
///
/// Mqtt events are for the user's information and do not require any special handling
/// Switch Case statements can be used to cover all derived classes for eg.
/// ```dart
/// void handleEvent(MqttEvent event){
///   switch (event){
///     case NetworkConnectionFailure():
///       handleNetworkConnectionFailure();
///      case ConnAckEvent():
///       handleConnAck();
///      default:
///       log(event.runtimeType);
///   }
/// }
/// ```
sealed class MqttEvent {}

/// The event when a socket/SSL-socket/websocket connection attempt failed
///
/// The library automatically retries connection after [KinnowMqttClient.retryInterval] in this case
class NetworkConnectionFailure extends MqttEvent {}

/// The event when an established network connection becomes disconnected after successful connecting
class NetworkEnded extends MqttEvent {}

/// The event when the broker sends a packet that cannot be understood by the library
class MalformedPacket extends MqttEvent {
  /// the bytes of the received packet
  final List<int>? packetBytes;

  /// additional information about why the packet was considered malformed
  final String? message;

  MalformedPacket(this.packetBytes, {this.message});
}

/// The event when the broker acknowledges the connection and sends a connAck packet
class ConnAckEvent extends MqttEvent {
  /// the ConnAckPacket sent by the broker
  ConnAckPacket connAck;

  ConnAckEvent(this.connAck);
}

/// The event when a ping request packet is sent
///
/// MQTT requires the client to send a ping message periodically so that it can
/// verify whether the broker is still reachable.
class PingReqSent extends MqttEvent {
  /// time at which the ping request was sent
  late DateTime sentAt;

  PingReqSent({DateTime? sentTime}) {
    sentAt = sentTime ?? DateTime.now();
  }
}

/// The event when a ping response packet is received
class PingRespReceived extends MqttEvent {
  /// time at which the ping response was received
  late DateTime receivedAt;

  PingRespReceived({DateTime? recvTime}) {
    receivedAt = recvTime ?? DateTime.now();
  }
}

/// The event when a ping request was sent but a ping response was not received within the keep alive duration
class PingRespNotReceived extends MqttEvent {}

/// The event when the broker does not respond to a connect packet withing three seconds
class ConnackTimedOut extends MqttEvent {}

/// The cause of the client shutting down
enum ShutdownType {
  /// the client disconnected from the broker intentionally on the user's request and the disconnect packet was sent
  clientInitiated,

  /// the client disconnected from the broker after automatically after receiving a malformed packet
  clientInitiatedMalformedPacket,

  /// the server sent a disconnect packet to the client
  serverInitiated,

  /// the connection could not be made and retrying is not an option. eg broker does not support MQTT5
  connectionNotPossible,

  /// the client disconnected from the broker intentionally on the user's request but the disconnect packet was NOT sent due to disconnection
  clientInitiatedNetworkUnavailable,
}

/// The event when the client has reached an unrecoverable state.
///
/// After this event is received. No further mqtt operations will complete successfully
class ShutDown extends MqttEvent {
  /// the cause of the shut down
  final ShutdownType type;

  /// contains the received disconnect packet in case [type] is serverInitiated
  /// contains the sent disconnect packet in case [type] is clientInitiatedMalformedPacket
  final DisconnectPacket? disconnectPacket;

  ShutDown(this.type, this.disconnectPacket);
}
