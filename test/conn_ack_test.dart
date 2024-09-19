import 'package:kinnow_mqtt/src/packets/conn_ack_packet.dart';
import 'package:test/test.dart';

void main() {
  test(
    "parse sniffed connAckPacket",
    () {
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
      expect(pkt, isNotNull);
      expect(pkt!.userProperties.isEmpty, true);
      expect(pkt.authData, isNull);
      expect(pkt.authMethod, isNull);
      expect(pkt.serverReference, isNull);
      expect(pkt.serverKeepAlive, isNull);
      expect(pkt.sharedSubscriptionAvailable, isNull);
      expect(pkt.subscriptionIdentifiersAvailable, isNull);
      expect(pkt.wildcardSubscriptionAvailable, isNull);
      expect(pkt.reasonString, isNull);
      expect(pkt.topicAliasMaximum, 5);
      expect(pkt.assignedClientId, isNull);
      expect(pkt.maxPacketSize, isNull);
      expect(pkt.retainAvailable, isNull);
      expect(pkt.maximumQOS, isNull);
      expect(pkt.receiveMaximum, 10);
      expect(pkt.sessionExpiryInterval, isNull);
      expect(pkt.connectReasonCode, ConnectReasonCode.success);
      expect(pkt.sessionPresent, false);
      expect(pkt.responseInformation, isNull);
    },
  );
}
