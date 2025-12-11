import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../providers/device_provider.dart';

class PurifierControlWidget extends StatelessWidget {
  final Device device;

  const PurifierControlWidget({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeviceProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(device.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        // 전원 스위치
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("전원", style: TextStyle(fontSize: 18)),
            Switch(
              value: device.isOn,
              onChanged: (_) => provider.toggleDevice(device),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 풍량 슬라이더
        Opacity(
          opacity: device.isOn ? 1 : 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("풍량(세기)", style: TextStyle(fontSize: 18)),
              Slider(
                value: device.speed,
                min: 0,
                max: 1,
                onChanged: device.isOn
                    ? (v) => provider.updatePurifierSpeed(device, v)
                    : null,
              ),
              Text("세기: ${(device.speed * 100).round()}%"),
            ],
          ),
        ),
      ],
    );
  }
}
