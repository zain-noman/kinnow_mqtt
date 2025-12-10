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
  bool _showLogsInHex = false;

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

  void updateLogFormat(bool showLogsInHex) {
    _showLogsInHex = showLogsInHex;
  }

  @override
  Widget build(BuildContext context) {
    return LogsProvider(
      logs,
      addLog,
      clearLogs,
      child: LogsDisplayFormatProvider(
        _showLogsInHex,
        updateLogFormat,
        child: widget.child,
      ),
    );
  }
}

class LogsDisplayFormatProvider extends InheritedWidget {
  final bool showLogsInHex;
  final void Function(bool showLogsInHex) updateLogFormat;

  const LogsDisplayFormatProvider(this.showLogsInHex, this.updateLogFormat,
      {super.key, required super.child});

  static LogsDisplayFormatProvider of(BuildContext context) {
    final LogsDisplayFormatProvider? result =
        context.dependOnInheritedWidgetOfExactType<LogsDisplayFormatProvider>();
    assert(result != null, 'No LogsDisplayFormatProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant LogsDisplayFormatProvider oldWidget) {
    return showLogsInHex != oldWidget.showLogsInHex;
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
    assert(result != null, 'No LogsProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(LogsProvider oldWidget) {
    return true; //logs.length != oldWidget.logs.length;
  }
}
