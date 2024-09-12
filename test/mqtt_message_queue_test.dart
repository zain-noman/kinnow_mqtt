import 'package:cutie_mqtt/src/mqtt_message_queue.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group(
    "mqtt message queue",
    () {
      test(
        "normal functioning",
        () async {
          final MqttMessageQueue q = MqttMessageQueue();
          final messagesReceived = <List<int>>[];
          q.messageStream.listen(messagesReceived.add);
          await q.addMessage([0]);
          expect(messagesReceived, [
            [0]
          ]);
        },
      );

      test(
        "pause functioning",
        () async {
          final MqttMessageQueue q = MqttMessageQueue();
          final messagesReceived = <List<int>>[];
          final sub = q.messageStream.listen(messagesReceived.add);
          sub.pause();
          bool fut1Completed = false;
          bool fut2Completed = false;
          bool fut3Completed = false;
          q.addMessage([0]).then((value) => fut1Completed = true);
          q.addMessage([1]).then((value) => fut2Completed = true);
          q.addMessage([2]).then((value) => fut3Completed = true);
          await Future.delayed(const Duration(seconds: 1));
          expect(messagesReceived, isEmpty);
          expect(fut1Completed, false);
          expect(fut2Completed, false);
          expect(fut3Completed, false);
          sub.resume();
          await Future.delayed(const Duration(seconds: 1));
          expect(messagesReceived, [[0],[1],[2]]);
          expect(fut1Completed, true);
          expect(fut2Completed, true);
          expect(fut3Completed, true);
        },
      );
    },
  );
}
