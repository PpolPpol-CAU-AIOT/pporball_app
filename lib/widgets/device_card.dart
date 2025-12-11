import 'package:flutter/material.dart';
import '../models/device.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final void Function()? onTap;

  const DeviceCard({super.key, required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              device.isOn ? Icons.power : Icons.power_off,
              color: device.isOn ? Colors.green : Colors.red,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              device.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(device.isOn ? "켜짐" : "꺼짐"),
          ],
        ),
      ),
    );
  }
}
