import 'dart:async';

typedef MqttOperation<T> = Future<void> Function(T state);

enum OperationResult {
  operationExecuted,
  operationCanceledByPause,
  operationCanceledByShutdown
}

class MqttOperationData<T> {
  final MqttOperation<T> operation;
  final int queueToken;
  final Completer<OperationResult> completer;

  MqttOperationData(this.operation, this.queueToken, this.completer);
}

class MqttOperationQueue<T> {
  final _pauseController = StreamController<bool>();
  final _queuedOperations = <MqttOperationData<T>>[];
  final _operationAddedNotifier = StreamController<Null>();
  T? _sessionState;

  int _nextToxenToGive = 0;

  int generateToken() {
    final retVal = _nextToxenToGive;
    _nextToxenToGive++;
    return retVal;
  }

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
      int queueToken, MqttOperation<T> operation) {
    if (_operationAddedNotifier.isClosed) {
      return Future.value(OperationResult.operationCanceledByShutdown);
    }
    final completer = Completer<OperationResult>();
    final opData = MqttOperationData(operation, queueToken, completer);
    var insertIdx = _queuedOperations
        .indexWhere((element) => element.queueToken > queueToken);
    if (insertIdx == -1) insertIdx = _queuedOperations.length;
    _queuedOperations.insert(insertIdx, opData);
    _operationAddedNotifier.add(null);
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
