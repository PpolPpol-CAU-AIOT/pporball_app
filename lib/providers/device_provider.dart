// lib/providers/device_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/device.dart';

class DeviceProvider extends ChangeNotifier {
  // 기기 목록
  List<Device> devices = [
    Device(id: "home1", name: "Smart Purifier", type: "purifier", isOn: false),
    Device(id: "home2", name: "Living Room Light", type: "light", isOn: false),
    Device(id: "home3", name: "Living Room Fan", type: "fan", isOn: false),
    // 더 추가하고 싶으면 여기!
  ];

  // 서버 IP (한 번만 바꾸면 끝!)
  static const String baseUrl = "http://pporball-hub.local:8080";  // ← 당신 집 IP만 바꾸세요

  Future<void> toggleDevice(Device device) async {
    final newState = !device.isOn;
    device.isOn = newState;
    notifyListeners();

    // 공기청정기 → 기존 API 그대로
    if (device.type == "purifier") {
      try {
        await http.post(
          Uri.parse("$baseUrl/api/airpurifier/control"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "deviceId": device.id,
            "power": newState,
            "speed": newState ? 0.5 : 0.0,
          }),
        );
      } catch (e) {
        print("공기청정기 제어 실패: $e");
        device.isOn = !newState;
        notifyListeners();
      }
    }
    // LED → 새로 만든 통합 API 사용
    else if (device.type == "light") {
      try {
        await http.post(
          Uri.parse("$baseUrl/device/control"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "target": "light",
            "command": newState ? "on" : "off",
          }),
        );
        print("LED ${newState ? '켜짐' : '꺼짐'}");
      } catch (e) {
        print("LED 제어 실패: $e");
        device.isOn = !newState;  // 실패하면 롤백
        notifyListeners();
      }
    }
    else if (device.type == "fan") {
      try {
        await http.post(
          Uri.parse("$baseUrl/device/control"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "target": "fan",
            "command": newState ? "on" : "off",
          }),
        );
        print("FAN ${newState ? '켜짐' : '꺼짐'}");
      } catch (e) {
        print("FAN 제어 실패: $e");
        device.isOn = !newState;  // 실패하면 롤백
        notifyListeners();
      }
    }
  }

  Future<void> updatePurifierSpeed(Device device, double speed) async {
    device.speed = speed;
    final newState = device.isOn;
    
    notifyListeners();

    try {
      await http.post(
        Uri.parse("$baseUrl/api/airpurifier/control"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
            "deviceId": device.id,
            "power": newState,
            "speed": newState ? speed : 0.0,
          }),
      );
      print("Purifier speed updated: $speed");
    } catch (e) {
      print("공기청정기 속도 조절 실패: $e");
    }
  }
}