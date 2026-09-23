import "dart:collection";

import "package:findmyot/models/device.dart";
import "package:findmyot/models/location.dart";
import "package:findmyot/providers/useapi_provider.dart";
import "package:flutter/material.dart";
import 'package:findmyot/models/result.dart';


class DevicesProvider extends UseapiProvider with ChangeNotifier{
  // final ApiService _apiService;
  // List<Device> _devices = [];
  final Map<int, Device> _devices = HashMap();
  List<Device> _devicesList = [];
  String? error = null;

  DevicesProvider({required super.apiService});

  List<Device> get devices => _devicesList;

  Future<void> fetchDevices() async {
    Result result = await apiService.fetchDevices();
    if (!result.success) {
      print(result.error);
      return;
    }
    // final List<Device> new_devices = [];
    for (int i = 0; i < result.data.length; i++) {
      if (_devices.containsKey(result.data[i]['id'])){
        continue;
      }

      Device d = Device.fromJson(result.data[i]);
      // new_devices.add(Device.fromJson(result.data[i]));
      _devices[d.id] = d;
    }
    // _devices = new_devices;
    _devicesList = _devices.values.toList();

    notifyListeners();
  }

  Future<Result> createDevice(DeviceCreate device) async {
    // print(device);
    // if (device == null) {
    //   return Result.failure(error: "Device is null");
    // }
    Result result = await apiService.createDevice(device);
    if (!result.success) {
      // print(result.error);
      return Result.failure(error: result.error);
    }

    return Result.success(null);
  }

  Future<void> fetchDevicesLocation() async {
    Result result;
    
    for (int id in _devices.keys) {
      Device device = _devices[id]!;
      result = await apiService.fetchDeviceLocation(device.id);
      if (!result.success){
        continue;
      }
      // print(result.data);
      device.location = Location.fromJson(result.data);
    }

    notifyListeners();
  }
}