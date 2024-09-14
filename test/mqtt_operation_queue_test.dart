import 'package:cutie_mqtt/src/mqtt_operation_queue.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group(
    "mqtt message queue",
    () {
      test(
        "normal functioning",
        () async {
          final q = MqttOperationQueue<int>();

          bool fut1Completed = false;
          bool fut2Completed = false;
          final opOrder = <int>[];

          q.addToQueueAndExecute(
            (state) async {
              await Future.delayed(const Duration(seconds: 2));
              expect(state, 1);
              opOrder.add(1);
            },
          ).then((_) => fut1Completed = true);
          q.addToQueueAndExecute(
            (state) async {
              expect(state, 1);
              opOrder.add(2);
            },
          ).then((_) => fut2Completed = true);
          await Future.delayed(const Duration(seconds: 1));
          expect(fut1Completed, false);
          expect(fut2Completed, false);

          q.start(1);
          await Future.delayed(const Duration(seconds: 3));
          expect(fut1Completed, true);
          expect(fut2Completed, true);
          expect(opOrder, [1, 2]);
        },
      );

      test(
        "pause functioning with dispose",
        () async {
          final q = MqttOperationQueue<int>();

          bool fut1Completed = false;

          q.addToQueueAndExecute(
            (state) async {
              expect(state, 1);
            },
          ).then((_) => fut1Completed = true);

          await Future.delayed(const Duration(seconds: 1));
          expect(fut1Completed, false);
          q.start(1);
          await Future.delayed(const Duration(seconds: 1));
          expect(fut1Completed, true);

          q.pause();

          bool fut2Completed = false;
          bool? fut2Val;
          q.addToQueueAndExecute(
            (state) async {
              expect(state, 1);
            },
          ).then((val) {
            fut2Completed = true;
            fut2Val = val;
          });
          await Future.delayed(const Duration(seconds: 1));
          expect(fut2Completed, false);
          q.dispose();
          await Future.delayed(const Duration(seconds: 1));
          expect(fut2Completed, true);
          expect(fut2Val, false);
        },
      );
    },
  );
}
