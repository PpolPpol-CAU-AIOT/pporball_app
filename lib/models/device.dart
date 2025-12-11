class Device {
  final String id;
  final String name;          // ex: Purifier
  final String type;          // purifier / fan / light
  bool isOn;                  // 현재 전원 상태
  double speed;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.isOn,
    this.speed = 0.5,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json["id"],
      name: json["name"],
      type: json["type"],
      isOn: json["isOn"],
      speed: (json["speed"] ?? 0.5).toDouble(),
    );
  }
}
