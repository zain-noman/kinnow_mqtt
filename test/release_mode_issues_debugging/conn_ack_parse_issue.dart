import 'package:kinnow_mqtt/kinnow_mqtt.dart';

void main(){
  final packetBytes = [
    0x20,
    0x09,
    0x00,
    0x00,
    0x06,
    0x21,
    0x00,
    0x0a,
    0x22,
    0x00,
    0x05
  ];
  final pkt = ConnAckPacket.fromBytes(packetBytes.skip(2));
  print(pkt?.receiveMaximum.toString());
}