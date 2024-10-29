import 'dart:async';

class ResettablePeriodicTimer {
  final void Function() callback;
  final Duration time;

  Timer? _currentTimer;

  ResettablePeriodicTimer({required this.time, required this.callback});

  void _internalCallback(){
    callback();
    _currentTimer = Timer(time, _internalCallback);
  }

  void start() {
    _currentTimer = Timer(time, _internalCallback);
  }

  void stop({required bool dispose}) {
    _currentTimer?.cancel();
    _currentTimer = null;
  }

  void reset() {
    _currentTimer?.cancel();
    _currentTimer = Timer(time, _internalCallback);
  }
}
