import 'dart:async';

typedef MqttOperation<T> = Future<void> Function(T state);

class MqttOperationQueue<T> {
  final _controller = StreamController<(MqttOperation<T>, Completer<bool>)>();
  final _queuedOperations = <(MqttOperation<T>, Completer<bool>)>[];
  late StreamSubscription<(MqttOperation<T>, Completer<bool>)> _sub;
  T? _sessionState;
  bool _pauseFlag = true;

  void _onStreamResume() {
    for (final msgAndComp in _queuedOperations) {
      _controller.add(msgAndComp);
    }
    _queuedOperations.clear();
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
        if (!_pauseFlag)_sub.resume();
      },
    );
    _sub.pause();
  }

  Future<bool> addToQueueAndExecute(MqttOperation<T> operation) {
    if (_controller.isClosed) return Future.value(false);
    final completer = Completer<bool>();
    if (_controller.isPaused) {
      _queuedOperations.add((operation, completer));
    } else {
      _controller.add((operation, completer));
    }
    return completer.future;
  }

  void pause() {
    _sub.pause();
    _pauseFlag = true;
  }

  void start(T sessionState) {
    _sessionState = sessionState;
    _sub.resume();
    _pauseFlag = false;
  }

  void dispose() {
    _controller.close();
    for (final (_, comp) in _queuedOperations) {
      comp.complete(false);
    }
  }
}
