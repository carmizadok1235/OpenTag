import "package:findmyot/models/device.dart";
import "package:findmyot/providers/useapi_provider.dart";
import "package:flutter/material.dart";


class DevicesProvider extends UseapiProvider with ChangeNotifier{
  // final ApiService _apiService;
  List<Device> devices = [];
  String? error = null;

  DevicesProvider({required super.apiService});

  Future<void> fetchDevices() async {
    try {
      devices = await apiService.fetchDevices();
    } catch (e) {
      error = "Failed to load devices.";
    }

    notifyListeners();
  }

  // void init() {
    
  // }
}