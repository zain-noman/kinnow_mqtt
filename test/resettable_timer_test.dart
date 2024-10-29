import 'package:kinnow_mqtt/src/resettable_periodic_timer.dart';
import 'package:test/test.dart';

void main() {
  group("Resettable timer", () {
    test("no reset case", () async {
      int callbackCount = 0;
      final myTimer = ResettablePeriodicTimer(
        time: const Duration(seconds: 1),
        callback: () => callbackCount++,
      );

      myTimer.start();
      await Future.delayed(const Duration(seconds: 3, milliseconds: 500));
      myTimer.stop(dispose: true);

      expect(callbackCount, 3);
      await Future.delayed(const Duration(seconds: 2));
      expect(callbackCount, 3);
    });
    test("intermittent reset case", () async {
      int callbackCount = 0;
      final myTimer = ResettablePeriodicTimer(
        time: const Duration(seconds: 1),
        callback: () => callbackCount++,
      );

      myTimer.start();
      for (double t = 0; t < 3; t += 0.5) {
        await Future.delayed(const Duration(milliseconds: 500));
        myTimer.reset();
      }
      myTimer.stop(dispose: true);

      expect(callbackCount, 0);
    });
    test("intermittent reset later stopped", () async {
      int callbackCount = 0;
      final myTimer = ResettablePeriodicTimer(
        time: const Duration(seconds: 1),
        callback: () => callbackCount++,
      );

      myTimer.start();
      for (double t = 0; t < 2; t += 0.5) {
        await Future.delayed(const Duration(milliseconds: 500));
        myTimer.reset();
      }
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
      myTimer.stop(dispose: true);

      expect(callbackCount, 1);
    });
    test("stop and restart", () async {
      int callbackCount = 0;
      final myTimer = ResettablePeriodicTimer(
        time: const Duration(seconds: 1),
        callback: () => callbackCount++,
      );

      myTimer.start();
      await Future.delayed(const Duration(seconds: 2, milliseconds: 500));
      myTimer.stop(dispose: false);

      expect(callbackCount, 2);

      myTimer.start();
      await Future.delayed(const Duration(seconds: 2, milliseconds: 500));
      myTimer.stop(dispose: true);
      expect(callbackCount, 4);
    });
  });
}

/*
// this test is to check if resources are freed correctly.
void main() async {
  final tmr = ResettablePeriodicTimer(
    time: Duration(seconds: 15),
    callback: () => print("yahoo"),
  );
  tmr.start();
  await Future.delayed(const Duration(seconds: 5));
  tmr.stop(dispose: true);
}
*/