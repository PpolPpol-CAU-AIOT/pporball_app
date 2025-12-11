import 'package:flutter/material.dart';
import '../models/placed_device.dart';
import '../widgets/placed_device_widget.dart';
import '../widgets/draggable_device_icon.dart';
import '../services/mqtt_service.dart';

class DevicePlacementScreen extends StatefulWidget {
  const DevicePlacementScreen({super.key});

  @override
  State<DevicePlacementScreen> createState() => _DevicePlacementScreenState();
}

class _DevicePlacementScreenState extends State<DevicePlacementScreen> {
  final GlobalKey _mapKey = GlobalKey();
  List<PlacedDevice> placedDevices = [];

  RenderBox? get _mapBox {
    final ctx = _mapKey.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject();
    return box is RenderBox ? box : null;
  }

  Offset _clampToArea(Offset pos, Size areaSize) {
    return Offset(
      pos.dx.clamp(0.0, areaSize.width),
      pos.dy.clamp(0.0, areaSize.height),
    );
  }

  void addDevice(String type, Offset globalPosition) {
    final box = _mapBox;
    if (box == null) return;
    final localPos = _clampToArea(box.globalToLocal(globalPosition), box.size);
    final newDevice = PlacedDevice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      position: localPos,
    );

    setState(() {
      placedDevices.add(newDevice);
    });

    _publishPlacement(newDevice, box.size);
  }

  void updatePosition(String id, Offset globalPosition) {
    final box = _mapBox;
    if (box == null) return;

    PlacedDevice? updated;
    final localPos =
        _clampToArea(box.globalToLocal(globalPosition), box.size);

    setState(() {
      placedDevices = placedDevices.map((d) {
        if (d.id == id) {
          updated = d.copyWith(position: localPos);
          return updated!;
        }
        return d;
      }).toList();
    });

    if (updated != null) {
      _publishPlacement(updated!, box.size);
    }
  }

  Future<void> _publishPlacement(PlacedDevice device, Size areaSize) async {
    final normalizedX =
        areaSize.width == 0 ? 0.0 : device.position.dx / areaSize.width;
    final normalizedY =
        areaSize.height == 0 ? 0.0 : device.position.dy / areaSize.height;

    await MqttService().sendPlacement(
      deviceId: device.id,
      type: device.type,
      x: normalizedX,
      y: normalizedY,
      areaWidth: areaSize.width,
      areaHeight: areaSize.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("가전 배치하기"),
        backgroundColor: const Color(0xFFEC947D),
      ),
      body: Stack(
        children: [
          // ⭐ 배치 영역
          DragTarget<String>(
            onAcceptWithDetails: (details) {
              addDevice(details.data, details.offset);
            },
            builder: (context, candidate, rejected) {
              return Container(
                key: _mapKey,
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey.shade100,
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: _LShapeMapPainter(),
                      size: Size.infinite,
                    ),
                    Center(
                      child: Text(
                        "가전을 이 공간에 드래그하여 배치하세요",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ⭐ 배치된 가전 표시
          ...placedDevices.map(
            (d) => PlacedDeviceWidget(
              device: d,
              onMove: (newPos) => updatePosition(d.id, newPos),
            ),
          ),

          // 오른쪽 하단 메뉴
          Positioned(
            right: 20,
            bottom: 20,
            child: Column(
              children: const [
                DraggableDeviceIcon(type: "light"),
                SizedBox(height: 16),
                DraggableDeviceIcon(type: "fan"),
                SizedBox(height: 16),
                DraggableDeviceIcon(type: "airpurifier"),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// 간단한 ㄱ자형 맵 페인터
class _LShapeMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF3C64D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final margin = size.width * 0.1;
    final top = size.height * 0.18;
    final bottom = size.height * 0.78;
    final notchDepth = size.height * 0.18;
    final notchWidth = size.width * 0.45;
    final right = size.width - margin;
    final left = margin;

    final path = Path()
      ..moveTo(left, top)
      ..lineTo(right, top)
      ..lineTo(right, bottom)
      ..lineTo(notchWidth, bottom)
      ..lineTo(notchWidth, bottom - notchDepth)
      ..lineTo(left, bottom - notchDepth)
      ..lineTo(left, top);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
