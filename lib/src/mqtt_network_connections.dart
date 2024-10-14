import 'dart:async';
import 'dart:io';

abstract class MqttNetworkConnection {
  Future<Stream<int>?> connect();

  Future<bool> transmit(Iterable<int> bytes);
}

class TcpMqttNetworkConnection implements MqttNetworkConnection {
  final String host;
  final int port;
  Socket? currentSocket;

  @override
  Future<Stream<int>?> connect() async {
    try {
      final socket = await Socket.connect(host, port);
      // socket.setOption(SocketOption.tcpNoDelay,true);
      currentSocket = socket;
      return socket.transform(StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          for (final d in data) {
            sink.add(d);
          }
        },
        handleDone: (sink) {
          sink.close();
          currentSocket = null;
        },
      ));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> transmit(Iterable<int> bytes) async {
    if (currentSocket == null) return false;
    currentSocket?.add(bytes.toList());
    return true;
  }

  TcpMqttNetworkConnection(this.host, this.port);
}

class SslTcpMqttNetworkConnection implements MqttNetworkConnection{
  SecureSocket? currentSocket;
  final Future<SecureSocket> Function() secureSocketMaker;

  @override
  Future<Stream<int>?> connect() async {
    try {
      final socket = await secureSocketMaker();
      currentSocket = socket;
      return socket.transform(StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          for (final d in data) {
            sink.add(d);
          }
        },
        handleDone: (sink) {
          sink.close();
          currentSocket = null;
        },
      ));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> transmit(Iterable<int> bytes) async {
    if (currentSocket == null) return false;
    currentSocket?.add(bytes.toList());
    return true;
  }

  SslTcpMqttNetworkConnection(this.secureSocketMaker);
}