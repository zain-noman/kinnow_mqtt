import 'dart:async';

enum _ResetTimerEvents { start, stop, reset }

class ResettablePeriodicTimer {
  final void Function() callback;
  final Duration time;
  final _eventStream = StreamController<_ResetTimerEvents>.broadcast();
  bool _dispose = false;

  ResettablePeriodicTimer({required this.time, required this.callback}) {
    _internalLoop();
  }

  void _internalLoop() async {
    // iterator ensures events arent missed. using firstWhere/first on the
    // stream is error prone
    StreamIterator<_ResetTimerEvents> iter =
        StreamIterator(_eventStream.stream);
    while (true) {
      do {
        await iter.moveNext();
      } while (iter.current != _ResetTimerEvents.start);

      Future<bool> iterMoveNextFut = iter.moveNext();
      while (true) {
        final eventReceived = await Future.any([
          iterMoveNextFut,
          Future.delayed(
            time,
            () => false,
          )
        ]);

        // no event triggered timeout occurred
        if (eventReceived == false) {
          callback();
          continue;
        }

        if (eventReceived && iter.current == _ResetTimerEvents.stop) {
          if (_dispose) return;
          break;
        }

        //reset received
        iterMoveNextFut = iter.moveNext();
      }
    }
  }

  void start() {
    _eventStream.add(_ResetTimerEvents.start);
  }

  void stop({required bool dispose}) {
    _dispose = dispose;
    _eventStream.add(_ResetTimerEvents.stop);
  }

  void reset() {
    _eventStream.add(_ResetTimerEvents.reset);
  }
}
