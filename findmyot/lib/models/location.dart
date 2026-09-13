
class Location {
  final double longitude;
  final double latitude;
  final String timestamp;

  const Location({
    required this.longitude, 
    required this.latitude,
    required this.timestamp
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      longitude: json["longitude"] as double,
      latitude: json["latitude"] as double,
      timestamp: json["timestamp"] as String
    );
  }
}