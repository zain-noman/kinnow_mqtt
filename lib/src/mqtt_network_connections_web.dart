import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';
import 'mqtt_network_connection_base.dart';

class SslTcpMqttNetworkConnection implements MqttNetworkConnection
{
  @override
  Future<void> close() {
    // TODO: implement close
    throw UnimplementedError();
  }

  @override
  Future<Stream<int>?> connect() {
    // TODO: implement connect
    throw UnimplementedError();
  }

  @override
  Future<bool> transmit(Iterable<int> bytes) {
    // TODO: implement transmit
    throw UnimplementedError();
  }

  SslTcpMqttNetworkConnection(void Function() secureSocketMaker);
}

class TcpMqttNetworkConnection implements MqttNetworkConnection
{
  @override
  Future<void> close() {
    // TODO: implement close
    throw UnimplementedError();
  }

  @override
  Future<Stream<int>?> connect() {
    // TODO: implement connect
    throw UnimplementedError();
  }

  @override
  Future<bool> transmit(Iterable<int> bytes) {
    // TODO: implement transmit
    throw UnimplementedError();
  }

  TcpMqttNetworkConnection(String host, int port);
}

class WebSocketMqttNetworkConnection implements MqttNetworkConnection {
  // ps this is the web socket implementation for web
  WebSocket? _webSocket;
  final String url;
  final Duration connectionTimeoutDuration;
  StreamSubscription? _onCloseSubscription;

  WebSocketMqttNetworkConnection(
      {required this.url,
      this.connectionTimeoutDuration = const Duration(seconds: 5)});

  @override
  Future<Stream<int>?> connect() async {
    _webSocket = WebSocket(url);
    _webSocket?.binaryType = "arraybuffer";

    try{
      await _webSocket?.onOpen.first.timeout(
          connectionTimeoutDuration
      );
    } on TimeoutException{
      _webSocket?.close();
      _webSocket = null;
      return null;
    }

    _onCloseSubscription = _webSocket?.onClose.listen((event) {
      _webSocket = null;
      _onCloseSubscription?.cancel();
      _onCloseSubscription = null;
    },);
    
    return _webSocket?.onMessage.transform(
        StreamTransformer.fromHandlers(
          handleData: (messageEvent, sink) {
            if (messageEvent.data.isA<JSArrayBuffer>()) {
              final bb = (messageEvent.data as JSArrayBuffer).toDart;
              final uList = Uint8List.view(bb);
              for (int i = 0; i < uList.length; i++) {
                sink.add(uList[i]);
              }
            }
          },
        )
    );
  }

  @override
  Future<bool> transmit(Iterable<int> bytes) async {
    if (_webSocket == null) return false;
    final u8 = Uint8List.fromList(bytes.toList());
    _webSocket?.send(u8.buffer.jsify()!); // send ArrayBuffer
    // _webSocket?.send(bytes.jsify()!);
    return true;
  }

  @override
  Future<void> close() async {
    _webSocket?.close();
  }
}
