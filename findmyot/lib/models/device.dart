import 'package:findmyot/models/location.dart';

class Device {
  final int id;
  final String name;
  Location? location;
  final String timePaired;

  Device({required this.id, required this.name, required this.location, required this.timePaired});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json["id"] as int,
      name: json["name"] as String,
      location: null,
      timePaired: json["time_paired"] as String
    );
  }
}

class DeviceCreate {
  final String name;
  final String symmetricKey;
  final String privateKey;
  final String timePaired;

  const DeviceCreate({required this.name, required this.symmetricKey, required this.privateKey, required this.timePaired});

  // factory DeviceCreate.fromJson(Map<String, dynamic> json) {
  //   return Device(
  //     id: json["id"] as int,
  //     timePaired: json["time_paired"] as String
  //   );
  // }
}