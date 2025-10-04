/// The base class for network connections that can be used for mqtt
abstract class MqttNetworkConnection {
  /// establish a connection
  Future<Stream<int>?> connect();

  /// send data on the connection. Returns success or failure
  Future<bool> transmit(Iterable<int> bytes);

  /// close an established connection
  Future<void> close();
}