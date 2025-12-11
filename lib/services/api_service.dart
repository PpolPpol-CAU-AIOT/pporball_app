// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/device.dart';

// class ApiService {
//   static const baseUrl = "http://127.0.0.1:3000";

//   static Future<List<Device>> getDevices() async {
//     final res = await http.get(Uri.parse("$baseUrl/devices"));
//     final List data = jsonDecode(res.body);
//     return data.map((e) => Device.fromJson(e)).toList();
//   }

//   static Future<bool> toggleDevice(String id) async {
//     final res = await http.post(Uri.parse("$baseUrl/device/$id/toggle"));
//     return res.statusCode == 200;
//   }

//   static Future<bool> setPowerLevel(String id, int level) async {
//     final res = await http.post(
//       Uri.parse("$baseUrl/device/$id/power"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"powerLevel": level}),
//     );
//     return res.statusCode == 200;
//   }
// }
