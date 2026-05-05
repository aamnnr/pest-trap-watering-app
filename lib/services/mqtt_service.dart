import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/foundation.dart';


class MqttService {
  late MqttServerClient client;
  final String broker = 'broker.hivemq.com';
  final int port = 1883;
  final String telemetryTopic = 'tanisolution/+/telemetry';

  void Function(String deviceId, String event, Map<String, dynamic>? data)? onTelemetry;

  Future<void> connect() async {
    client = MqttServerClient(broker, 'flutter_app_${DateTime.now().millisecondsSinceEpoch}');
    client.port = port;
    client.keepAlivePeriod = 20; // set keep alive di sini, bukan di connection message
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;

    final connMsg = MqttConnectMessage()
        .withClientIdentifier(client.clientIdentifier)
        .startClean();
    client.connectionMessage = connMsg;

    try {
      await client.connect();
    } catch (e) {
      debugPrint('MQTT connection error: $e');
      client.disconnect();
      return;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      client.subscribe(telemetryTopic, MqttQos.atLeastOnce);
      client.updates!.listen(_onMessage);
    }
  }

  void _onConnected() => debugPrint('MQTT connected');
  void _onDisconnected() => debugPrint('MQTT disconnected');

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final msg in messages) {
      final topic = msg.topic;
      // Cast ke MqttPublishMessage untuk akses payload
      final publishMsg = msg as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(publishMsg.payload.message);
      final parts = topic.split('/');
      if (parts.length == 3 && parts[0] == 'tanisolution' && parts[2] == 'telemetry') {
        final deviceId = parts[1];
        try {
          final json = jsonDecode(payload);
          final event = json['event'] ?? 'telemetry';
          final data = (json['data'] is Map) ? Map<String, dynamic>.from(json['data']) : null;
          if (onTelemetry != null) {
            onTelemetry!(deviceId, event, data);
          }
        } catch (e) {
          debugPrint('JSON parse error: $e');
        }
      }
    }
  }

  void publishCommand(String deviceId, Map<String, dynamic> command) {
    final topic = 'tanisolution/$deviceId/command';
    final payload = jsonEncode(command);
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void disconnect() => client.disconnect();
}