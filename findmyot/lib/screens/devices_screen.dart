import "package:flutter/material.dart";
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final MapController _mapController = MapController();

  // Placeholder device locations — replace with your real device data
  final List<Map<String, dynamic>> _devices = [
    {"name": "Device 1", "position": LatLng(32.0853, 34.7818)}, // Tel Aviv
    {"name": "Device 2", "position": LatLng(32.1848, 34.8713)}, // Ra'anana
    {"name": "Device 3", "position": LatLng(31.7683, 35.2137)}, // Jerusalem
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Devices"),
        centerTitle: true,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(32.0853, 34.7818), // starting point
          initialZoom: 8,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=${String.fromEnvironment("MAP_API_KEY")}",
            userAgentPackageName: "findmyot", 
          ),
          MarkerLayer(
            markers: _devices.map((device) {
              return Marker(
                point: device["position"],
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    _showDeviceInfo(device["name"]);
                  },
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showDeviceInfo(String deviceName) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            deviceName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
