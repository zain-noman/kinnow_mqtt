import 'dart:async';

typedef MqttOperation<T> = Future<void> Function(T state);

enum OperationResult {
  operationExecuted,
  // on pause the operation is removed from the queue, this is helpful in scenarios where
  // you want to modify the operation or some data in it before re-queueing
  operationCanceledByPause,
  operationCanceledByShutdown,
  operationTimedOut
}

class MqttOperationToken {
  final int tokenId;
  late Timer? _timeoutTimer;
  void Function()? _onTimeout;

  void _timeoutCb() {
    if (_onTimeout != null) {
      _onTimeout!();
    }
  }

  MqttOperationToken(this.tokenId, Duration? timeoutDuration) {
    _timeoutTimer =
        timeoutDuration == null ? null : Timer(timeoutDuration, _timeoutCb);
  }

  static int _tokenIdGenerator = 1;

  factory MqttOperationToken.generateToken({Duration? timeout}) {
    final id = _tokenIdGenerator;
    _tokenIdGenerator++;
    return MqttOperationToken(id, timeout);
  }

  bool isTimedOut() =>
      _timeoutTimer == null ? false : !(_timeoutTimer!.isActive);

  void setTimeoutCallback(void Function()? cb) => _onTimeout = cb;

  void disarmTimeout() {
    _timeoutTimer?.cancel();
    _onTimeout = null;
    _timeoutTimer = null;
  }
}

class MqttOperationData<T> {
  final MqttOperation<T> operation;
  final MqttOperationToken queueToken;
  final Completer<OperationResult> completer;

  MqttOperationData(this.operation, this.queueToken, this.completer);
}

class MqttOperationQueue<T> {
  final _pauseController = StreamController<bool>();
  final _queuedOperations = <MqttOperationData<T>>[];
  final _operationAddedNotifier = StreamController<Null>();
  T? _sessionState;

  MqttOperationQueue() {
    _internalLoop();
  }

  Future<bool> _waitIterValue(StreamIterator<bool> iter, bool value) async {
    while (true) {
      final gotValue = await iter.moveNext();
      if (!gotValue) return false;
      if (iter.current == value) return true;
    }
  }

  void _internalLoop() async {
    final pauseIterator = StreamIterator(_pauseController.stream);
    final opAddedIterator = StreamIterator(_operationAddedNotifier.stream);

    Future<bool> opAddedFut = opAddedIterator.moveNext();
    while (true) {
      //wait for start
      final iterGetSuccess = await _waitIterValue(pauseIterator, false);
      if (!iterGetSuccess) return;

      var pauseIteratorEventFut = _waitIterValue(pauseIterator, true);
      // execute queued operations until pause is received
      while (true) {
        //get operation
        var pauseReceived = false;
        while (_queuedOperations.isEmpty) {
          var exit = false;
          final opReceived = await Future.any([
            opAddedFut.then(
              (value) {
                exit = !value;
                return true;
              },
            ),
            pauseIteratorEventFut.then(
              (value) {
                exit = !value;
                return false;
              },
            )
          ]);
          if (exit) return;
          if (!opReceived) {
            pauseReceived = true;
            break;
          }
          opAddedFut = opAddedIterator.moveNext();
        }
        if (pauseReceived) break;
        //insertions should ensure _queuedOperations is sorted by queueToken
        final op = _queuedOperations.first;

        op.queueToken.disarmTimeout();
        final opFut = op.operation(_sessionState as T);
        bool exit = false;
        final opCompleted = await Future.any([
          opFut.then((value) => true),
          pauseIteratorEventFut.then((streamNotEnded) {
            if (streamNotEnded == false) exit = true;
            return false;
          })
        ]);
        if (opCompleted) {
          op.completer.complete(OperationResult.operationExecuted);
          _queuedOperations.remove(op);
        } else {
          if (exit) return;
          break;
        }
      }

      //complete remaining with Operation Canceled By Pause
      while (_queuedOperations.isNotEmpty) {
        final op = _queuedOperations.first;
        op.completer.complete(OperationResult.operationCanceledByPause);
        _queuedOperations.remove(op);
      }
    }
  }

  Future<OperationResult> addToQueueAndExecute(
      MqttOperationToken queueToken, MqttOperation<T> operation) {
    if (_operationAddedNotifier.isClosed) {
      return Future.value(OperationResult.operationCanceledByShutdown);
    }

    if (queueToken.isTimedOut()) {
      return Future.value(OperationResult.operationTimedOut);
    }

    final completer = Completer<OperationResult>();
    final opData = MqttOperationData(operation, queueToken, completer);
    var insertIdx = _queuedOperations.indexWhere(
        (element) => element.queueToken.tokenId > queueToken.tokenId);
    if (insertIdx == -1) insertIdx = _queuedOperations.length;
    _queuedOperations.insert(insertIdx, opData);
    _operationAddedNotifier.add(null);
    queueToken.setTimeoutCallback(
      () {
        _queuedOperations.remove(opData);
        completer.complete(OperationResult.operationTimedOut);
      },
    );

    return completer.future;
  }

  void pause() {
    if (_pauseController.isClosed) return;
    _pauseController.add(true);
  }

  void start(T sessionState) {
    if (_pauseController.isClosed) return;
    _sessionState = sessionState;
    _pauseController.add(false);
  }

  void dispose() {
    _pauseController.close();
    _operationAddedNotifier.close();
    for (final opData in _queuedOperations) {
      if (!opData.completer.isCompleted) {
        opData.completer.complete(OperationResult.operationCanceledByShutdown);
      }
    }
  }
}
