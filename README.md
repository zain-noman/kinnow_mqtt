# Kinnow MQTT 🍊

![icon](kinnow-mqtt-icon.png)
A Mqtt 5 Client for dart. Key features include

### 1. Detailed insights

Kinnow Mqtt client functions will return any corresponding acknowledgement packets. For example
calling subscribe will return the SubAck Packet sent by the broker, A publishQos1 call will return
the PubAck. For events that occur without any calls such as ping requests and ping response, An
event stream is provided

### 2. Built for Unreliable Networks

The library is built with unreliable networks in mind. The client ensures that operations (
subscribe, publish etc) are completed regardless of connection state. This means the user doesn't
need to monitor the connection status before starting any operation.

#### Timeout functionality

Kinnow Mqtt allows setting timeouts for messages, it's asynchronous API allows users to easily 
implement time sensitive functionality. For instance consider the following snippet
```dart
if (await client.publishQos0(
      TxPublishPacket(
        false,"TestTopic", StringOrBytes.fromString("TestPayload")),
      timeout: const Duration(seconds: 5))
){
  print("The message was published within the timeout duration");
} else {
  print("The message timed out and was discarded");
}
```

### 3. Async APIs

Kinnow Mqtt APIs return Futures. This allows users to wait for some operation to complete before
starting new ones. For example consider the following snippet for testing loop back
```dart
final suback = await client.subscribe(SubscribePacket([
  TopicSubscription("TopicXYZ", MqttQos.exactlyOnce),
]));
if (suback != null && suback.reasonCodes.first == SubackReasonCode.grantedQoS2) {
  // we got a Subscribe Acknowledgement from the broker and the subscription was successful
  // now the sent message will be received as well.
  final qos2res = await client.publishQos2(TxPublishPacket(
    false, "TopicXYZ", StringOrBytes.fromString("A QoS2 message")));
}
```

### 4. Message storage

Have a scenario where it is crucial that every message is sent. Kinnow MQTT provides a Mqtt Message 
storage feature, this allows users to check what messages were unsent in their last session so that 
they can be sent in the new session.

## Client Lifecycle

![Client Lifecycle](Kinnow_Mqtt_Lifecycle.png)

## What's with the name?

Kinnow (pronounced kee-noo) is a fruit grown in Pakistan and India. Its a specie of orange, but is a
bit less tangy and more pulpy.

## Minimal Example
```dart
  // the KinnowMqttClient client class is the main class through which all
  // mqtt interactions will happen
  final client = KinnowMqttClient(
      TcpMqttNetworkConnection("your.brokers.address.here.com", 1883));
  // start the client, it will now handle connection and communication,
  // the event stream will inform about different internal events
  final eventStream = client.begin(ConnectPacket(
    cleanStart: true,
    lastWill: null,
    keepAliveSeconds: 60,
    username: null,
    password: null,
  ));
  // listening to the event stream at least once is mandatory to start 
  // the lifecycle, the events themselves can be ignored if not needed
  eventStream.listen(
    (event) => print(event.runtimeType),
  );

  // listening to received messages
  client.receivedMessagesStream.listen(
      (event) => print("Packet Received "
    "\n \t topic: ${event.topic},"
    "\n \t qos: ${event.qos},"
    "\n \t payload: ${event.payload.asString}"),
  );
  
  // publishing messages
  await client.publishQos0(TxPublishPacket(
    false,
    "kinnowTestTopic",
    StringOrBytes.fromString("A QoS 0 message"),
  ));

  // subscribing to topics
  await client.subscribe(SubscribePacket([
    TopicSubscription("KinnowSubTopic1", MqttQos.atMostOnce),
  ]));
```

## Mqtt Client Demo Application

![Demo App Screenshot](desktop_demo_app.png)
To quickly evaluate Kinnow Mqtt, check out the Kinnow Mqtt flutter demo application right in your
browser on [this link](https://zain-noman.github.io/kinnow-mqtt-web-demo/). The source code is  
located in the directory `example/kinnow_mqtt_flutter_example`. A snap package for linux is also
available in the releases section

The demo application has the following features.

1. Implements many of the advanced features of MQTT5, and can be used to test them
2. The codebase showcases how Kinnow Mqtt may be implemented in a flutter application
3. The app can be used to evaluate how Kinnow Mqtt handles connections, disconnections etc.

## Roadmap
Kinnow Mqtt implements major functionality of the MQTT protocol but does lack some
features which are to be implemented in future releases.
1. Implementing Authentication Packets
2. Handling Server initiated disconnections