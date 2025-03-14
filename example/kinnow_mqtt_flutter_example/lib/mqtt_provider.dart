import 'package:flutter/material.dart';
import 'package:kinnow_mqtt/kinnow_mqtt.dart';

class MqttProviderBase extends StatefulWidget {
  final Widget child;
  final void Function(MqttEvent event, BuildContext context) onMqttEvent;

  // for this project it made sense to have a single message handler in the provider.
  // for other projects it is recommended to have a stream listener for each component
  // that needs to listen to messages
  final void Function(RxPublishPacket message, BuildContext context)? onMessageReceive;

  const MqttProviderBase(
      {super.key, required this.child, required this.onMqttEvent, this.onMessageReceive});

  @override
  State<MqttProviderBase> createState() => _MqttProviderBaseState();
}

class _MqttProviderBaseState extends State<MqttProviderBase> {
  KinnowMqttClient? _client;

  void updateClient(ConnectPacket connectPkt, MqttNetworkConnection connection,
      {String? clientId}) {
    if (_client != null && _client!.isRunning()) {
      _client!.disconnect();
    }
    setState(() {
      _client = KinnowMqttClient(connection, initClientId: clientId);
    });
    final eventStream = _client!.begin(connectPkt);
    eventStream.listen(
      (event) {
        if (!mounted) return;
        widget.onMqttEvent(event, context);
      },
    );
    if (widget.onMessageReceive != null) {
      _client!.receivedMessagesStream.listen(
        (event) {
          if (!mounted) return;
          widget.onMessageReceive!(event, context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MqttProvider(_client, updateClient, child: widget.child);
  }
}

class MqttProvider extends InheritedWidget {
  const MqttProvider(
    this.client,
    this.updateClient, {
    super.key,
    required super.child,
  });

  final KinnowMqttClient? client;
  final void Function(
      ConnectPacket connectPkt, MqttNetworkConnection connection,
      {String? clientId}) updateClient;

  static MqttProvider of(BuildContext context) {
    final MqttProvider? result =
        context.dependOnInheritedWidgetOfExactType<MqttProvider>();
    assert(result != null, 'No MqttProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(MqttProvider oldWidget) {
    return client != oldWidget.client;
  }
}
