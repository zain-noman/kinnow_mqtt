import "package:flutter/material.dart";

sealed class MqttEventLog {
  final bool isSentByClient;

  MqttEventLog({required this.isSentByClient});
}

class GenericMqttEventLog extends MqttEventLog {
  final String title;
  final String? subtitle;
  final Map<String, String> data;

  GenericMqttEventLog(
      {required super.isSentByClient,
      required this.title,
      this.subtitle,
      this.data = const {}});
}

class GenericMqttLogWidget extends StatelessWidget {
  final GenericMqttEventLog log;

  const GenericMqttLogWidget(this.log, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          log.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
        if (log.subtitle != null)
          Flexible(
            child: Text(
              log.subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
        const SizedBox(height: 10,),
        ...log.data.entries.map((e) => Row(
          mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${e.key}: ",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                Flexible(
                  child: Text(
                    e.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                )
              ],
            ))
      ],
    );
  }
}
