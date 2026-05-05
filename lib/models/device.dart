class Device {
  final String id;
  int battery;
  bool isNight;
  bool uvOn;
  bool pumpOn;
  DateTime? lastSeen;

  Device({
    required this.id,
    this.battery = 0,
    this.isNight = false,
    this.uvOn = false,
    this.pumpOn = false,
    this.lastSeen,
  });
}