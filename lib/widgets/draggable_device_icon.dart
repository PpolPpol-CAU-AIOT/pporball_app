import 'package:flutter/material.dart';

class DraggableDeviceIcon extends StatelessWidget {
  final String type;
  final Color color;

  const DraggableDeviceIcon({
    super.key,
    required this.type,
    this.color = const Color(0xFFEC947D),
  });

  IconData get icon {
    switch (type) {
      case "light":
        return Icons.lightbulb_outline;
      case "fan":
        return Icons.toys;
      case "airpurifier":
        return Icons.air;
      default:
        return Icons.devices_other;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: type,
      feedback: Material(
        color: Colors.transparent,
        child: Icon(icon, size: 48, color: color.withOpacity(0.8)),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Icon(icon, size: 48, color: color),
      ),
      child: Icon(icon, size: 48, color: color),
    );
  }
}
