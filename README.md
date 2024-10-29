# Kinnow MQTT 🍊
A Mqtt 5 Client for dart. Key features include

### 1. Lifecycle Management
The Kinnow Mqtt Client will retry on automatically retry connection if it fails. It will also reconnect if the connection breaks after reconnection. The lifecycle is explained in detail in a later section.

### 2. Detailed insights
Kinnow Mqtt client functions will return any corresponding acknowledgement packets. For example calling subscribe will return the SubAck Packet sent by the broker, A publishQos1 call will return the PubAck. For events that occur without any calls such as ping requests and ping response, An event stream is provided

### 3. Built for Unreliable Networks
The library is built with unreliable networks in mind. The client ensures that operations are completed regardless of connection state. This means the user doesn't need to monitor the connection status before starting any operation

## Client Lifecycle
![Client Lifecycle](Kinnow_Mqtt_Lifecycle.png)

## What's with the name?
Kinnow (pronounced kee-noo) is a fruit grown in Pakistan and India. Its very similar to orange, but is a bit less tangy and more pulpy.

## Contributing
The project is still in its initial stages and needs your help!!. If you face any issue, please do report it. If you have any feature request, also mention it in the issues. 

## Roadmap
1. Adding support for Websockets
2. Mqtt Message Storage (WIP)
3. Implementing Authentication Packets
4. Handling Server initiated disconnections