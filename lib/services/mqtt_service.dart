import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/foundation.dart';

class MqttService {
  late MqttServerClient client;

  final String broker = 'broker.hivemq.com';
  final int port = 1883;

  final String telemetryTopic = 'tanisolution/+/telemetry';

  void Function(String deviceId, String event, Map<String, dynamic>? data)?
  onTelemetry;

  bool get isConnected =>
      client.connectionStatus?.state == MqttConnectionState.connected;

  Future<void> connect() async {
    try {
      // jika sudah connect jangan connect ulang
      if (isConnected) {
        debugPrint('MQTT already connected');
        return;
      }
    } catch (_) {}

    client = MqttServerClient(
      broker,
      'flutter_app_${DateTime.now().millisecondsSinceEpoch}',
    );

    client.port = port;

    client.keepAlivePeriod = 20;

    // AUTO RECONNECT
    client.autoReconnect = true;
    client.resubscribeOnAutoReconnect = true;

    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;

    final connMsg = MqttConnectMessage()
        .withClientIdentifier(client.clientIdentifier)
        .startClean();

    client.connectionMessage = connMsg;

    try {
      debugPrint('Connecting to MQTT broker...');

      await client.connect();
    } catch (e) {
      debugPrint('MQTT connection error: $e');

      disconnect();
      return;
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      debugPrint('MQTT connected successfully');

      client.subscribe(telemetryTopic, MqttQos.atLeastOnce);

      client.updates?.listen(_onMessage);
    } else {
      debugPrint('MQTT failed: ${client.connectionStatus}');
    }
  }

  void _onConnected() {
    debugPrint('MQTT connected');
  }

  void _onDisconnected() {
    debugPrint('MQTT disconnected');
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final msg in messages) {
      if (msg.payload is MqttPublishMessage) {
        final topic = msg.topic;

        final publishMessage = msg.payload as MqttPublishMessage;

        final payload = MqttPublishPayload.bytesToStringAsString(
          publishMessage.payload.message,
        );

        final parts = topic.split('/');

        if (parts.length == 3 &&
            parts[0] == 'tanisolution' &&
            parts[2] == 'telemetry') {
          final deviceId = parts[1];

          try {
            final json = jsonDecode(payload);

            if (json.containsKey('bat') &&
                json.containsKey('is_night') &&
                json.containsKey('uv')) {
              final Map<String, dynamic> data = Map<String, dynamic>.from(json);

              onTelemetry?.call(deviceId, 'telemetry', data);
            } else if (json.containsKey('event')) {
              final String event = json['event'];

              final data = (json['data'] is Map)
                  ? Map<String, dynamic>.from(json['data'])
                  : null;

              onTelemetry?.call(deviceId, event, data);
            }
          } catch (e) {
            debugPrint('JSON parse error: $e');
          }
        }
      }
    }
  }

  void publishCommand(String deviceId, Map<String, dynamic> command) {
    if (!isConnected) {
      debugPrint('Gagal mengirim: MQTT tidak terhubung');
      return;
    }

    final topic = 'tanisolution/$deviceId/command';

    final payload = jsonEncode(command);

    debugPrint('Publish topic: $topic');
    debugPrint('Payload: $payload');

    final builder = MqttClientPayloadBuilder();

    builder.addString(payload);

    try {
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);

      debugPrint('Publish success');
    } catch (e) {
      debugPrint('Publish error: $e');
    }
  }

  void disconnect() {
    try {
      client.disconnect();
    } catch (_) {}
  }
}
