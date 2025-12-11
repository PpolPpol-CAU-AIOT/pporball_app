import 'package:flutter/material.dart';
import '../models/placed_device.dart';

class PlacedDeviceWidget extends StatelessWidget {
  final PlacedDevice device;
  final Function(Offset newPosition) onMove;

  const PlacedDeviceWidget({
    super.key,
    required this.device,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: device.position.dx,
      top: device.position.dy,
      child: Draggable<PlacedDevice>(
        data: device,
        feedback: Opacity(
          opacity: 0.7,
          child: Icon(Icons.circle, size: 50, color: Colors.orange),
        ),
        onDragEnd: (details) {
          final newPos = details.offset;
          onMove(newPos);
        },
        child: GestureDetector(
          onTap: () {
            // 상세 제어 페이지 연결 가능
            print("${device.type} tapped");
          },
          child: _buildIcon(device.type),
        ),
      ),
    );
  }

  Widget _buildIcon(String type) {
    IconData icon;
    switch (type) {
      case "light":
        icon = Icons.lightbulb_outline;
        break;
      case "fan":
        icon = Icons.toys;
        break;
      case "airpurifier":
        icon = Icons.air;
        break;
      default:
        icon = Icons.devices;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEC947D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}
