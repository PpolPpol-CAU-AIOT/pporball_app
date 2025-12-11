import 'dart:ui';

class PlacedDevice {
  final String id;
  final String type; // "light", "fan", "airpurifier"
  Offset position;

  PlacedDevice({
    required this.id,
    required this.type,
    required this.position,
  });

  PlacedDevice copyWith({Offset? position}) {
    return PlacedDevice(
      id: id,
      type: type,
      position: position ?? this.position,
    );
  }
}
