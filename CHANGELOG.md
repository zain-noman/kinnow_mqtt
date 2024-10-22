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