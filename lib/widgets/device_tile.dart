import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../providers/device_provider.dart';
import '../theme.dart';
import '../screens/device_detail_screen.dart';

// lib/widgets/device_tile.dart (기존 그대로 + 아이콘만 타입별로)
class DeviceTile extends StatelessWidget {
  final Device device;

  const DeviceTile({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    switch (device.type) {
      case "airpurifier":
      case "purifier":
        iconData = Icons.air;
        break;
      case "light":
        iconData = Icons.lightbulb;
        break;
      case "fan":                    // ← 이거만 추가
        iconData = Icons.mode_fan_off; // ← 이거만 추가 (선풍기 아이콘)
        break;
      default:
        iconData = Icons.device_unknown;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DeviceDetailScreen(device: device),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: device.isOn ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              iconData,
              color: device.isOn ? Colors.white : Colors.black87,
              size: 32,
            ),
            const Spacer(),
            Text(
              device.name,
              style: TextStyle(
                color: device.isOn ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Switch(
                value: device.isOn,
                activeColor:
                    device.type == "light" ? Colors.amber : Colors.cyan,
                onChanged: (_) {
                  context.read<DeviceProvider>().toggleDevice(device);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
