import 'dart:async';
import 'dart:io';

abstract class MqttNetworkConnection {
  Future<Stream<int>?> connect();

  void transmit(Iterable<int> bytes);
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
      ));
    } catch (e) {
      return null;
    }
  }

  @override
  void transmit(Iterable<int> bytes) {
    currentSocket!.add(bytes.toList());
  }

  TcpMqttNetworkConnection(this.host, this.port);
}