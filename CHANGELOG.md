## 0.0.1

* initial release.

## 0.0.2

* unsubscribe feature added

## 0.0.3

* Feat: TLS/SSL support added 
* Feat: Major update in documentation
* Feat: Keep alive period and reconnect delay are now separate
* Feat: If server provides a keep alive in ConnAck, it will be used
* Feat: Improvements in example
* Bugfix: PubRel messages are now sent with the correct flags. (fixes QoS2 transmission)
* Bugfix: PubRel messages weren't being sent in response to PubRec (fixes QoS2 reception)

## 0.0.4

* Malformed packet handling 
* Ensuring everything is disposed when the client shuts down

## 0.9.0

* replace isar mqtt message storage with file based storage
* added a new example flutter project
* fix bug in handling socket errors

## 0.9.1

* fixed an issue in connack packet that only occurred in release mode
* renamed the example flutter project
* fixed the message shown for QoS0 packets in example app
* added snap builds for linux
* created a logo!!!

## 0.9.2

* fixed a mistake in the pubspec path of the demo app
* updated the readme to feature the demo app
* fixed a mistake in the .desktop file used for the linux snap package

## 0.9.3

* packages upgraded
* added websocket support
* added browser support
* created browser version of flutter example