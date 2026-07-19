

class Device {
  final int id;
  final String timePaired;

  const Device({required this.id, required this.timePaired});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json["id"] as int,
      timePaired: json["time_paired"] as String
    );
  }
}