import "package:findmyot/models/device.dart";
import "package:findmyot/providers/useapi_provider.dart";
import "package:findmyot/services/api_service.dart";
import "package:flutter/material.dart";
import 'package:findmyot/models/result.dart';


class DevicesProvider extends UseapiProvider with ChangeNotifier{
  // final ApiService _apiService;
  List<Device> _devices = [];
  String? error = null;

  DevicesProvider({required super.apiService});

  List<Device> get devices => _devices;

  Future<void> fetchDevices() async {
    Result result = await apiService.fetchDevices();
    if (!result.success) {
      print(result.error);
      return;
    }
    final List<Device> new_devices = [];
    for (int i = 0; i < result.data.length; i++) {
      new_devices.add(Device.fromJson(result.data[i]));
    }
    _devices = new_devices;

    notifyListeners();
  }

  Future<Result> createDevice(DeviceCreate? device) async {
    print(device);
    if (device == null) {
      return Result.failure(error: "Device is null");
    }
    Result result = await apiService.createDevice(device);
    if (!result.success) {
      // print(result.error);
      return Result.failure(error: result.error);
    }

    return Result.success(null);
  }
}