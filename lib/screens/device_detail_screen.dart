import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../providers/device_provider.dart';
import '../widgets/purifier_control_widget.dart';

class DeviceDetailScreen extends StatelessWidget {
  final Device device; // 전달받지만 이건 초기 reference일 뿐

  const DeviceDetailScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    // 🔥 Provider에서 최신 device 상태를 다시 가져옴
    final provider = context.watch<DeviceProvider>();
    final currentDevice =
        provider.devices.firstWhere((d) => d.id == device.id);

    print("DETAIL TYPE = ${currentDevice.type}  isOn=${currentDevice.isOn}");

    return Scaffold(
      appBar: AppBar(
        title: Text("${currentDevice.name} 제어"),
        backgroundColor: const Color(0xFFEC947D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildControlUI(context, currentDevice),
      ),
    );
  }

  Widget _buildControlUI(BuildContext context, Device currentDevice) {
    switch (currentDevice.type) {
      case "airpurifier":
      case "purifier":
        return PurifierControlWidget(device: currentDevice);  // 🔥 최신 device 전달

      case "light":
      case "fan":
        return _buildBasicPowerControl(context, currentDevice);

      default:
        return const Text("이 기기는 제어 UI가 존재하지 않습니다.");
    }
  }

  Widget _buildBasicPowerControl(BuildContext context, Device dev) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Text(dev.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        Switch(
          value: dev.isOn,
          activeColor: const Color(0xFFEC947D),
          onChanged: (_) {
            context.read<DeviceProvider>().toggleDevice(dev);
          },
        ),

        const SizedBox(height: 10),
        Text(
          dev.isOn ? "현재 상태: 켜짐" : "현재 상태: 꺼짐",
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
