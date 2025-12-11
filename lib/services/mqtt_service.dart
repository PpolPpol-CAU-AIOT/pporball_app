import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// MQTT 전송 전용 서비스 (싱글톤)
class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal() {
    _client = MqttServerClient.withPort(_broker, _clientId, _port)
      ..logging(on: false)
      ..keepAlivePeriod = 30
      ..onConnected = () => debugPrint("✅ MQTT connected");
    _client.onDisconnected = () => debugPrint("⚠️ MQTT disconnected");
  }

  final String _broker = "pporball-hub.local";
  final int _port = 1883;
  final String _topicPlacement = "pporball/placement";
  final String _clientId =
      "pporball_flutter_${DateTime.now().millisecondsSinceEpoch}";

  late MqttServerClient _client;
  bool _isConnecting = false;

  Future<void> _ensureConnected() async {
    if (_client.connectionStatus?.state == MqttConnectionState.connected ||
        _isConnecting) {
      return;
    }

    _isConnecting = true;
    try {
      await _client.connect();
    } catch (e) {
      debugPrint("MQTT connect error: $e");
      _client.disconnect();
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> sendPlacement({
    required String deviceId,
    required String type,
    required double x,
    required double y,
    required double areaWidth,
    required double areaHeight,
  }) async {
    await _ensureConnected();
    if (_client.connectionStatus?.state != MqttConnectionState.connected) {
      debugPrint("MQTT is not connected, skipping publish");
      return;
    }

    final payload = jsonEncode({
      "deviceId": deviceId,
      "type": type,
      "position": {"x": x, "y": y}, // 0~1 normalized
      "area": {"width": areaWidth, "height": areaHeight},
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });

    final builder = MqttClientPayloadBuilder()..addUTF8String(payload);
    _client.publishMessage(
      _topicPlacement,
      MqttQos.atLeastOnce,
      builder.payload!,
    );

    debugPrint("📡 MQTT publish → $_topicPlacement : $payload");
  }

  void dispose() {
    _client.disconnect();
  }
}
