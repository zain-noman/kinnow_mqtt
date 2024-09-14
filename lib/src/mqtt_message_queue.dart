import 'dart:async';

class MqttMessageQueue {
  final _controller = StreamController<(List<int>, Completer<bool>)>();
  final _unsentMessages = <(List<int>,Completer<bool>)>[];
  void _onStreamResume(){
    for (final msgAndComp in _unsentMessages){
      _controller.add(msgAndComp);
    }
    _unsentMessages.clear();
  }

  MqttMessageQueue(){
    _controller.onResume = _onStreamResume;
  }

  Future<bool> addMessage(List<int> message) {
    final completer = Completer<bool>();
    if (_controller.isPaused){
      _unsentMessages.add((message, completer));
    }else {
      _controller.add((message, completer));
    }
    return completer.future;
  }

  Stream<List<int>> get messageStream => _controller.stream.map(
        (event) {
          final (list, completer) = event;
          completer.complete(true);
          return list;
        },
      );

  void dispose() {
    _controller.close();
    for (final (_,comp) in _unsentMessages){
      comp.complete(false);
    }
  }
}
