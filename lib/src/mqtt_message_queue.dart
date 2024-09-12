import 'dart:async';

class MqttMessageQueue {
  final StreamController<(List<int>, Completer<void>)> _controller =
      StreamController<(List<int>, Completer<void>)>();

  Future<void> addMessage(List<int> message) {
    final completer = Completer<void>();
    _controller.add((message,completer));
    return completer.future;
  }

  Stream<List<int>> get messageStream => _controller.stream.map((event){
    final (list,completer) = event;
    completer.complete();
    return list;
  },);

  void dispose(){
    _controller.close();
  }
}
