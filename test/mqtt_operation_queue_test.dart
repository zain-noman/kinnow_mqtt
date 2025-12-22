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

          final token1 = MqttOperationToken.generateToken();
          final token2 = MqttOperationToken.generateToken();

          q.addToQueueAndExecute(
            token1,
            (state) async {
              await Future.delayed(const Duration(seconds: 2));
              expect(state, 1);
              opOrder.add(1);
            },
          ).then((_) => fut1Completed = true);
          q.addToQueueAndExecute(
            token2,
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

          final token3 = MqttOperationToken.generateToken();
          final fut3success = await q.addToQueueAndExecute(
            token3,
            (state) async {
              expect(state, 1);
              opOrder.add(3);
            },
          );
          expect(fut3success, OperationResult.operationExecuted);
          expect(opOrder, [1, 2, 3]);

          q.pause();
          await Future.delayed(const Duration(seconds: 1));
          final token4 = MqttOperationToken.generateToken();
          q.addToQueueAndExecute(
            token4,
            (state) async {
              expect(state, 1);
              opOrder.add(4);
            },
          );
          q.addToQueueAndExecute(
            token1,
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

          final token1 = MqttOperationToken.generateToken();
          q.addToQueueAndExecute(
            token1,
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
          final token2 = MqttOperationToken.generateToken();
          q.addToQueueAndExecute(
            token2,
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
      test(
        "timeout behavior",
        () async {
          final q = MqttOperationQueue<int>();
          final token =
              MqttOperationToken.generateToken(timeout: Duration(seconds: 2));
          bool opRan = false;
          OperationResult? res;
          q.addToQueueAndExecute(
            token,
            (state) async {
              opRan = true;
            },
          ).then(
            (value) => res = value,
          );

          final token2 =
              MqttOperationToken.generateToken(timeout: Duration(seconds: 4));
          bool op2Ran = false;
          OperationResult? res2;
          expect(token2.isTimedOut(), false);
          q.addToQueueAndExecute(
            token2,
            (state) async {
              op2Ran = true;
            },
          ).then(
            (value) => res2 = value,
          );

          await Future.delayed(Duration(seconds: 3));
          q.start(0);
          await Future.delayed(Duration(seconds: 1));
          expect(opRan, false);
          expect(res, OperationResult.operationTimedOut);
          expect(op2Ran, true);
          expect(res2, OperationResult.operationExecuted);
          q.dispose();
        },
      );
    },
  );
}
