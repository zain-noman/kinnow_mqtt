import 'dart:io';

import 'package:kinnow_mqtt/kinnow_mqtt.dart';
import 'package:test/test.dart';

void main() {
  test("Successful HiveMq Connection", () async {
    final client = KinnowMqttClient(SslTcpMqttNetworkConnection(
      () => SecureSocket.connect(
        "broker.hivemq.com",
        8883,
        onBadCertificate: (certificate) {
          print("Bad certificate");
          return false;
        },
      ),
    ));
    final connPkt = ConnectPacket(
      cleanStart: true,
      lastWill: null,
      keepAliveSeconds: 5,
      username: null,
      password: null,
    );
    final eventStream = client.begin(connPkt);
    eventStream.listen(
      (event) => print(event.runtimeType),
    );
    final connack = (await eventStream
        .firstWhere((element) => element is ConnAckEvent)) as ConnAckEvent;
    expect(connack, isNotNull);
    expect(connack.connAck.connectReasonCode, ConnectReasonCode.success);
  });

  // test("Successful local TlS Connection", () async {
  //   final client = KinnowMqttClient(SslTcpMqttNetworkConnection(
  //     () => SecureSocket.connect(
  //       "127.0.0.1",
  //       8883,
  //       context: SecurityContext()
  //         ..setTrustedCertificatesBytes(utf8.encode(
  //             "-----BEGIN CERTIFICATE-----\n"
  //             "MIIDkzCCAnugAwIBAgIUM8nVGQGmHZPA2Dt6xtx5bztDifkwDQYJKoZIhvcNAQEL\n"
  //             "BQAwWTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM\n"
  //             "GEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDESMBAGA1UEAwwJbG9jYWxob3N0MB4X\n"
  //             "DTI0MTAxNDIxNDYwOVoXDTI1MTAxNDIxNDYwOVowWTELMAkGA1UEBhMCQVUxEzAR\n"
  //             "BgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoMGEludGVybmV0IFdpZGdpdHMgUHR5\n"
  //             "IEx0ZDESMBAGA1UEAwwJbG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A\n"
  //             "MIIBCgKCAQEAoqH5VM/yNwe6yK6wPqGRWUwHm7sR1WgP9Pq65PAa8HdU1S+USmZB\n"
  //             "tD1lr+xMGBqLNmGf0FBNs5gfSO2rGwi57bFkVHZ/MNt7XA55O12wQtU+28URwCFK\n"
  //             "3qRmGteAJdB/qUuqqdqqnAASZTRpyiHZikvCc7sIxX+wZdambRQJNFU9F6kaEUQQ\n"
  //             "UX+v1KeIR5ekXXA+SRAv5QnjBJ7MhUT3N3WutkLfiDqVVXyZKCXkk3fkM0+ZOH5U\n"
  //             "vf6WyZtC/asjVXLDZ7BwJXBY4qwk0UdN/depwl3IwbtxEcP3iZ6h8nyCzTsFCPbO\n"
  //             "pST8L01D8HVtsaXldqr+1IHmT327dDDAqQIDAQABo1MwUTAdBgNVHQ4EFgQUQzLc\n"
  //             "A2NxUTn+NyF7ffuC0qcTHIQwHwYDVR0jBBgwFoAUQzLcA2NxUTn+NyF7ffuC0qcT\n"
  //             "HIQwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAA+7X8W6ZruT0\n"
  //             "0ICQl42AT7/wCLrnyzoZe+1wMiZLe10FD1pHj9uMQ0BcQe4PKyMK6Wvq0OOrSVyJ\n"
  //             "GFvTacAmkoQHnwDCMr75vSLUcMLCdD7tjL32juF0Ej41PWJBeuLJ5Ke8LXqMRi4l\n"
  //             "dOgNgqTeDuCm8X7gdraYuf7OHFTjk1vxrWPVpKtTuScSPqKmI9bOtmtPhbbdqhaR\n"
  //             "5/WXvHCyDd85FDLRrZO1RaU5Hbh0VAvXf9VuDrltF5fBwWQX82e2n1cKZYfoGgRN\n"
  //             "5KiAgB5ke+jWrm1M7lsZUm4vebniUycLOZIPDiyqfJYRDbhVI4ETXAeYJXQzjzow\n"
  //             "wNeP3b87Bg==\n"
  //             "-----END CERTIFICATE-----\n")),
  //       onBadCertificate: (certificate) {
  //         print("Bad certificate");
  //         return false;
  //       },
  //     ),
  //   ));
  //   final connPkt = ConnectPacket(
  //     cleanStart: true,
  //     lastWill: null,
  //     keepAliveSeconds: 5,
  //     username: "WutIsLuv",
  //     password: StringOrBytes.fromString("BabyDontHurtMe"),
  //   );
  //   final eventStream = client.begin(connPkt);
  //   eventStream.listen(
  //     (event) => print(event.runtimeType),
  //   );
  //   final connack = (await eventStream
  //       .firstWhere((element) => element is ConnAckEvent)) as ConnAckEvent;
  //   expect(connack, isNotNull);
  //   expect(connack.connAck.connectReasonCode, ConnectReasonCode.success);
  // });
}
