import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mqtt_client/mqtt_client.dart'; // Tambahkan import ini untuk MqttConnectionState
import '../models/device.dart';
import '../models/log_entry.dart';
import '../services/mqtt_service.dart';

class DeviceProvider extends ChangeNotifier {
  final MqttService mqttService;
  final Map<String, Device> _devices = {};
  List<LogEntry> _logs = [];

  DeviceProvider(this.mqttService) {
    mqttService.onTelemetry = _handleTelemetry;
    _loadLogsFromStorage();
    _loadDevicesFromStorage();
    _initMqtt();
  }

  void _initMqtt() async {
    await mqttService.connect();
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  // === HANDLE INCOMING TELEMETRY / EVENT ===
  void _handleTelemetry(
    String deviceId,
    String event,
    Map<String, dynamic>? data,
  ) {
    final now = DateTime.now();

    // Update atau buat device
    Device device;
    if (_devices.containsKey(deviceId)) {
      device = _devices[deviceId]!;
    } else {
      device = Device(id: deviceId);
      _devices[deviceId] = device;
    }
    device.lastSeen = now;

    // Proses berdasarkan event
    if (event == 'telemetry' && data != null) {
      device.battery = data['bat'] ?? device.battery;
      device.isNight = data['is_night'] ?? device.isNight;
      device.uvOn = (data['uv'] == 1);
      // pump status tidak selalu ada, kita biarkan dari event pump_on/off
    } else if (event == 'uv_on') {
      device.uvOn = true;
    } else if (event == 'uv_off') {
      device.uvOn = false;
    } else if (event == 'pump_on') {
      device.pumpOn = true;
    } else if (event == 'pump_off') {
      device.pumpOn = false;
    }
    // event lain seperti "wifi_reset", "uv_schedule_updated", dll bisa diabaikan untuk status device

    // Tambahkan log
    final log = LogEntry(
      deviceId: deviceId,
      timestamp: now,
      event: event,
      data: data,
    );
    _logs.insert(0, log);

    // Simpan log ke SharedPreferences (maks 1000 log terbaru agar tidak membengkak)
    _saveLogsToStorage();

    // Simpan data perangkat agar tidak hilang saat restart
    _saveDevicesToStorage();

    notifyListeners();
  }

  // === KIRIM PERINTAH ===
  void sendCommand(String deviceId, Map<String, dynamic> command) {
    mqttService.publishCommand(deviceId, command);
  }

  // === HAPUS LOG ===
  Future<void> clearLogs({String? deviceId}) async {
    if (deviceId == null) {
      _logs.clear();
    } else {
      _logs.removeWhere((log) => log.deviceId == deviceId);
    }
    await _saveLogsToStorage();
    notifyListeners();
  }

  // === HAPUS PERANGKAT ===
  Future<void> deleteDevice(String deviceId) async {
    if (_devices.containsKey(deviceId)) {
      _devices.remove(deviceId);
      // Hapus juga log yang terkait
      _logs.removeWhere((log) => log.deviceId == deviceId);
      
      await _saveDevicesToStorage();
      await _saveLogsToStorage();
      notifyListeners();
    }
  }

  // === GETTERS ===
  List<Device> get devices => _devices.values.toList();

  Device? getDevice(String id) => _devices[id];

  List<LogEntry> get allLogs => _logs;

  List<LogEntry> logsForDevice(String id) =>
      _logs.where((log) => log.deviceId == id).toList();

  int get onlineCount => _devices.values.where((d) {
    if (d.lastSeen == null) return false;
    return DateTime.now().difference(d.lastSeen!).inMinutes < 5;
  }).length;

  // === GETTER STATUS MQTT ===
  bool get isMqttConnected {
    try {
      if (mqttService.client.connectionStatus == null) return false;
      return mqttService.client.connectionStatus!.state ==
          MqttConnectionState.connected;
    } catch (e) {
      return false;
    }
  }

  // === PENYIMPANAN LOG & DEVICE LOKAL ===
  static const _logKey = 'device_logs';
  static const _deviceKey = 'saved_devices';

  Future<void> _saveDevicesToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _devices.values.map((e) => e.toJson()).toList();
    prefs.setString(_deviceKey, jsonEncode(jsonList));
  }

  Future<void> _loadDevicesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_deviceKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      for (var item in jsonList) {
        final device = Device.fromJson(item);
        _devices[device.id] = device;
      }
      notifyListeners();
    }
  }

  Future<void> _saveLogsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    // Simpan maksimal 1000 log agar tidak terlalu besar
    final logsToSave = _logs.take(1000).toList();
    final jsonList = logsToSave.map((e) => e.toJson()).toList();
    prefs.setString(_logKey, jsonEncode(jsonList));
  }

  Future<void> _loadLogsFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_logKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _logs = jsonList.map((e) => LogEntry.fromJson(e)).toList();
      notifyListeners();
    }
  }
}
