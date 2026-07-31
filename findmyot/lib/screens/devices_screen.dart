import 'package:findmyot/models/device.dart';
import 'package:findmyot/providers/devices_provider.dart';
import 'package:findmyot/providers/useapi_provider.dart';
import 'package:findmyot/widgets/add_device_dialog.dart';
// import 'package:findmyot/widgets/error_dialog.dart';
import 'package:findmyot/widgets/status_dialog.dart';
import "package:flutter/material.dart";
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

const String MAP_API_KEY = String.fromEnvironment("MAP_API_KEY");

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final MapController _mapController = MapController();

  // need to change it, devices should be fetched via provider using service call for the api.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(32.0853, 34.7818), // starting point
              initialZoom: 8,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$MAP_API_KEY",
                userAgentPackageName: "findmyot", 
              ),
            ],
          ),
          _buildDraggableDeviceList()
        ],
      )
    );
  }

  Widget _buildDraggableDeviceList() {
    final DevicesProvider _devicesProvider = context.watch<DevicesProvider>();
    
    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Material(
              color: Colors.transparent, // let the Container's white bg show through
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Devices",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.blue, size: 28),
                                onPressed: () async {
                                  // await _devicesProvider.fetchDevices();
                                  final DeviceCreate? device = await showDialog<DeviceCreate>(
                                    context: context, 
                                    builder: (context) => AddDeviceDialog()
                                  );

                                  Result res = await _devicesProvider.createDevice(device);
                                  if (res.success) {
                                    await _devicesProvider.fetchDevices();
                                  } else {
                                    // showDialog(
                                    //   context: context,
                                    //   builder: (context) => ErrorDialog(message: res.error!)
                                    // );
                                    showStatusDialog(
                                      context, 
                                      status: DialogStatus.error, 
                                      message: res.error!
                                    );
                                  }
                                  // handle add device
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final device = _devicesProvider.devices[index];
                        return ListTile(
                          leading: const Icon(Icons.devices, color: Colors.blue),
                          title: Text(device.id.toString()),
                          subtitle: const Text("Tap to view on map"),
                          onTap: () {
                            // _mapController.move(device["position"], 14);
                          },
                        );
                      },
                      childCount: _devicesProvider.devices.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
