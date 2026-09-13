import 'package:findmyot/models/location.dart';

class Device {
  final int id;
  Location? location;
  final String timePaired;

  Device({required this.id, required this.location, required this.timePaired});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json["id"] as int,
      location: null,
      timePaired: json["time_paired"] as String
    );
  }
}

class DeviceCreate {
  final String symmetricKey;
  final String privateKey;
  final String timePaired;

  const DeviceCreate({required this.symmetricKey, required this.privateKey, required this.timePaired});

  // factory DeviceCreate.fromJson(Map<String, dynamic> json) {
  //   return Device(
  //     id: json["id"] as int,
  //     timePaired: json["time_paired"] as String
  //   );
  // }
}