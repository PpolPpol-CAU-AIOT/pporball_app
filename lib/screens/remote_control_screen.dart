import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RemoteControlScreen extends StatefulWidget {
  const RemoteControlScreen({super.key});

  @override
  State<RemoteControlScreen> createState() => _RemoteControlScreenState();
}

class _RemoteControlScreenState extends State<RemoteControlScreen> {
  final String streamUrl = "http://192.168.137.194:9000/stream";
  final String apiUrl = "http://pporball-hub.local:8080/device/control";
  static const Color _primaryColor = Color(0xFFEC947D);

  Uint8List? currentFrame;
  StreamSubscription<List<int>>? _sub;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _startStream();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // ================================
  // MJPEG STREAM
  // ================================
  void _startStream() async {
    setState(() => _loading = true);

    final req = http.Request("GET", Uri.parse(streamUrl));
    final res = await req.send();

    final boundary = _extractBoundary(res.headers);
    if (boundary == null) {
      debugPrint("❌ Could not find MJPEG boundary.");
      setState(() => _loading = false);
      return;
    }

    final boundaryBytes = utf8.encode(boundary);
    List<int> buffer = [];
    bool insideFrame = false;

    _sub = res.stream.listen((chunk) {
      buffer.addAll(chunk);

      int pos = _indexOfSublist(buffer, boundaryBytes);

      if (pos != -1) {
        if (insideFrame) {
          final jpegBytes = Uint8List.fromList(buffer.sublist(0, pos));
          if (jpegBytes.isNotEmpty) {
            setState(() => currentFrame = jpegBytes);
          }
        }

        buffer = buffer.sublist(pos + boundaryBytes.length);

        final headerEnd = _findHeaderEnd(buffer);
        if (headerEnd != -1) {
          buffer = buffer.sublist(headerEnd);
          insideFrame = true;
        }
      }
    });

    setState(() => _loading = false);
  }

  String? _extractBoundary(Map<String, String> headers) {
    final ct = headers["content-type"];
    if (ct == null) return null;

    final parts = ct.split("boundary=");
    if (parts.length < 2) return null;

    return "--${parts[1].trim()}";
  }

  int _findHeaderEnd(List<int> data) {
    for (int i = 0; i < data.length - 3; i++) {
      if (data[i] == 13 &&
          data[i + 1] == 10 &&
          data[i + 2] == 13 &&
          data[i + 3] == 10) {
        return i + 4;
      }
    }
    for (int i = 0; i < data.length - 1; i++) {
      if (data[i] == 10 && data[i + 1] == 10) {
        return i + 2;
      }
    }
    return -1;
  }

  int _indexOfSublist(List<int> data, List<int> pattern) {
    for (int i = 0; i <= data.length - pattern.length; i++) {
      bool match = true;
      for (int j = 0; j < pattern.length; j++) {
        if (data[i + j] != pattern[j]) {
          match = false;
          break;
        }
      }
      if (match) return i;
    }
    return -1;
  }

  // ================================
  // ROBOT CONTROL
  // ================================
  Future<void> sendRobotCommand(String direction) async {
    final payload = {"target": "robot", "direction": direction};

    try {
      final res = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      debugPrint("Sent → $payload");
      debugPrint("Response → ${res.body}");
    } catch (e) {
      debugPrint("❌ HTTP Error: $e");
    }
  }

  Widget controlButton({
    required IconData icon,
    required String direction,
    Color color = _primaryColor,
  }) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () => sendRobotCommand(direction),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  // ================================
  // FINAL UI (STACK LAYOUT)
  // ================================
@override
Widget build(BuildContext context) {
  final image = currentFrame;

  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      title: const Text("로봇 원격 조종"),
      backgroundColor: const Color(0xFFEC947D),
    ),
    body: Stack(
      children: [
        // ===============================
        // 📌 고정 크기 스트리밍 박스
        // ===============================
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 260, // <<<<< 영상 크기 고정
            color: Colors.black12,
            child: Center(
              child: _loading
                  ? const CircularProgressIndicator()
                  : image == null
                      ? const Text("카메라 연결 중…")
                      : Image.memory(
                          image,
                          gaplessPlayback: true,
                          filterQuality: FilterQuality.low,
                        ),
            ),
          ),
        ),

        // ===============================
        // 📌 조이스틱: 화면 중앙 아래 정렬
        // ===============================
        Positioned(
          left: 0,
          right: 0,
          bottom: 70, // ← 기존 120보다 더 아래로 내림
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              controlButton(icon: Icons.keyboard_arrow_up, direction: "up"),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  controlButton(icon: Icons.keyboard_arrow_left, direction: "left"),
                  const SizedBox(width: 12),
                  controlButton(
                    icon: Icons.stop_circle,
                    direction: "stop",
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 12),
                  controlButton(icon: Icons.keyboard_arrow_right, direction: "right"),
                ],
              ),
              const SizedBox(height: 12),
              controlButton(icon: Icons.keyboard_arrow_down, direction: "down"),
            ],
          ),
        ),

        // ===============================
        // 📌 댄스 버튼: 오른쪽 아래로 더 내림
        // ===============================
        Positioned(
          right: 20,
          bottom: 85, // 기존보다 더 아래로 내림
          child: SizedBox(
            width: 130,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => sendRobotCommand("dance"),
              child: const Text(
                "DANCE",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

}
