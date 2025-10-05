import 'dart:async';
import 'dart:io';
import 'mqtt_network_connection_base.dart';

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
        handleError: (error, stackTrace, sink) {
          if (error is SocketException) {
            sink.close();
          }
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
        handleError: (error, stackTrace, sink) {
          if (error is SocketException) {
            sink.close();
          }
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

/// Mqtt Connection that uses WebSockets
///
/// implementations exist for both browser and non-browser applications.
/// To use secure websockets simply use a url that has "wss://broker-address"
/// instead of "ws://broker-address"
class WebSocketMqttNetworkConnection implements MqttNetworkConnection{

  final String url;
  WebSocket? _currentSocket;

  WebSocketMqttNetworkConnection({required this.url});

  @override
  Future<Stream<int>?> connect() async{
    try {
      final socket = await WebSocket.connect(url);
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
        handleError: (error, stackTrace, sink) {
          if (error is SocketException) {
            sink.close();
          }
        },
      ));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> close() async {
    _currentSocket?.close();
    _currentSocket = null;
  }

  @override
  Future<bool> transmit(Iterable<int> bytes) async {
    if (_currentSocket == null) return false;
    _currentSocket?.add(bytes.toList());
    return true;
  }
}