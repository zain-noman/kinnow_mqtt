import 'package:flutter/material.dart';

import 'mqtt_logs.dart';

class LogsProviderBase extends StatefulWidget {
  final Widget child;

  const LogsProviderBase({super.key, required this.child});

  @override
  State<LogsProviderBase> createState() => _LogsProviderBaseState();
}

class _LogsProviderBaseState extends State<LogsProviderBase> {
  final logs = <MqttEventLog>[];

  void addLog(MqttEventLog log) {
    setState(() {
      logs.add(log);
    });
  }

  void clearLogs() {
    setState(() {
      logs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LogsProvider(logs, addLog, clearLogs, child: widget.child);
  }
}

class LogsProvider extends InheritedWidget {
  const LogsProvider(
    this.logs,
    this.addLog,
    this.clearLogs, {
    super.key,
    required super.child,
  });

  final List<MqttEventLog> logs;
  final void Function(MqttEventLog) addLog;
  final void Function() clearLogs;

  static LogsProvider of(BuildContext context) {
    final LogsProvider? result =
        context.dependOnInheritedWidgetOfExactType<LogsProvider>();
    assert(result != null, 'No MqttProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(LogsProvider oldWidget) {
    return true;//logs.length != oldWidget.logs.length;
  }
}
