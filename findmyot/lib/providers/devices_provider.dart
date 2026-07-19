import "package:findmyot/models/device.dart";
import "package:findmyot/providers/useapi_provider.dart";
import "package:findmyot/services/api_service.dart";
import "package:flutter/material.dart";


class DevicesProvider extends UseapiProvider with ChangeNotifier{
  // final ApiService _apiService;
  List<Device> _devices = [];
  String? error = null;

  DevicesProvider({required super.apiService});

  List<Device> get devices => _devices;

  Future<void> fetchDevices() async {
    ApiResult result = await apiService.fetchDevices();
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

  // void init() {
    
  // }
}