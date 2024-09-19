import 'package:kinnow_mqtt/src/mqtt_operation_queue.dart';
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
            1,
            (state) async {
              await Future.delayed(const Duration(seconds: 2));
              expect(state, 1);
              opOrder.add(1);
            },
          ).then((_) => fut1Completed = true);
          q.addToQueueAndExecute(
            2,
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

          final fut3success = await q.addToQueueAndExecute(
            3,
                (state) async {
              expect(state, 1);
              opOrder.add(3);
            },
          );
          expect(fut3success, OperationResult.operationExecuted);
          expect(opOrder, [1,2,3]);

          q.pause();
          await Future.delayed(const Duration(seconds: 1));
          q.addToQueueAndExecute(
            4,
            (state) async {
              expect(state, 1);
              opOrder.add(4);
            },
          );
          q.addToQueueAndExecute(
            1,
            (state) async {
              expect(state, 1);
              opOrder.add(1);
            },
          );
          q.start(1);
          await Future.delayed(const Duration(seconds: 1));
          expect(opOrder, [1, 2, 3, 1, 4]);
        },
      );
      test(
        "pause functioning with dispose",
        () async {
          final q = MqttOperationQueue<int>();

          bool fut1Completed = false;

          q.addToQueueAndExecute(
            1,
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
          await Future.delayed(const Duration(seconds: 1));

          bool fut2Completed = false;
          OperationResult? fut2Val;
          q.addToQueueAndExecute(
            2,
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
          await Future.delayed(const Duration(seconds: 2));
          expect(fut2Completed, true);
          expect(fut2Val, OperationResult.operationCanceledByShutdown);
        },
      );
    },
  );
}
