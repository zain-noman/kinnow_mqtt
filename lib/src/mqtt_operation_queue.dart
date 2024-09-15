import 'dart:async';

typedef MqttOperation<T> = Future<void> Function(T state);

class MqttOperationQueue<T> {
  final _controller = StreamController<(MqttOperation<T>, Completer<bool>)>();
  final _unsentMessages = <(MqttOperation<T>, Completer<bool>)>[];
  late StreamSubscription<(MqttOperation<T>, Completer<bool>)> _sub;
  T? _sessionState;

  void _onStreamResume() {
    for (final msgAndComp in _unsentMessages) {
      _controller.add(msgAndComp);
    }
    _unsentMessages.clear();
  }

  MqttOperationQueue() {
    _controller.onResume = _onStreamResume;
    _sub = _controller.stream.listen(null);
    _sub.onData(
      (data) async {
        _sub.pause();
        final (operaton, completer) = data;
        await operaton(_sessionState as T);
        completer.complete(true);
        _sub.resume();
      },
    );
    _sub.pause();
  }

  Future<bool> addToQueueAndExecute(MqttOperation<T> operation) {
    final completer = Completer<bool>();
    if (_controller.isPaused) {
      _unsentMessages.add((operation, completer));
    } else {
      _controller.add((operation, completer));
    }
    return completer.future;
  }

  void pause() {
    _sub.pause();
  }

  void start(T sessionState) {
    _sessionState = sessionState;
    _sub.resume();
  }

  void dispose() {
    _controller.close();
    for (final (_, comp) in _unsentMessages) {
      comp.complete(false);
    }
  }
}
