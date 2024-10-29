import 'dart:async';
import 'dart:io';

/// The base class for network connections that can be used for mqtt
abstract class MqttNetworkConnection {
  /// establish a connection
  Future<Stream<int>?> connect();

  /// send data on the connection. Returns success or failure
  Future<bool> transmit(Iterable<int> bytes);

  /// close an established connection
  Future<void> close();
}

/// Mqtt Connection that uses simple TCP sockets without encryption
///
/// the host uri is commonly in the form `mqtt://broker.name.here.com`
class TcpMqttNetworkConnection implements MqttNetworkConnection {
  /// Ip address or uri of the mqtt broker
  final String host;

  /// The port for socket connection. 1883 is commonly used
  final int port;
  Socket? _currentSocket;

  @override
  Future<Stream<int>?> connect() async {
    try {
      final socket = await Socket.connect(host, port);
      // socket.setOption(SocketOption.tcpNoDelay,true);
      _currentSocket = socket;
      return socket.transform(StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          for (final d in data) {
            sink.add(d);
          }
        },
        handleDone: (sink) {
          sink.close();
          _currentSocket = null;
        },
      ));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> transmit(Iterable<int> bytes) async {
    if (_currentSocket == null) return false;
    _currentSocket?.add(bytes.toList());
    return true;
  }

  TcpMqttNetworkConnection(this.host, this.port);

  @override
  Future<void> close() async {
    _currentSocket?.destroy();
    _currentSocket = null;
  }
}

/// Mqtt Connection that uses TCP sockets with encryption using TLS/SSL
///
/// This is also commonly referred to as MQTTS
/// the host uri is commonly in the form `mqtts://broker.name.here.com`
class SslTcpMqttNetworkConnection implements MqttNetworkConnection {
  SecureSocket? _currentSocket;

  /// A function to create a [SecureSocket]
  ///
  /// eg. ```SecureSocket.connect("broker.address.com",8883)```
  final Future<SecureSocket> Function() secureSocketMaker;

  @override
  Future<Stream<int>?> connect() async {
    try {
      final socket = await secureSocketMaker();
      _currentSocket = socket;
      return socket.transform(StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          for (final d in data) {
            sink.add(d);
          }
        },
        handleDone: (sink) {
          sink.close();
          _currentSocket = null;
        },
      ));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> transmit(Iterable<int> bytes) async {
    if (_currentSocket == null) return false;
    _currentSocket?.add(bytes.toList());
    return true;
  }

  /// Create a SSL TCP Network Connection Object
  ///
  /// [secureSocketMaker] is usually set in the following way
  /// ```dart
  /// SslTcpMqttNetworkConnection(
  ///       () => SecureSocket.connect(
  ///         "broker.address.com",
  ///         8883,
  ///       ),
  ///     )
  /// ```
  SslTcpMqttNetworkConnection(this.secureSocketMaker);

  @override
  Future<void> close() async {
    _currentSocket?.destroy();
    _currentSocket = null;
  }
}
