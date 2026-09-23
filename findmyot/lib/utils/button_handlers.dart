import 'package:findmyot/models/device.dart';
import 'package:findmyot/providers/auth_provider.dart';
import "package:findmyot/models/user.dart";
import 'package:findmyot/models/result.dart';
import 'package:findmyot/providers/devices_provider.dart';
import 'package:findmyot/utils/apple.dart';
import 'package:flutter/material.dart';

class UserHandlers {
  static Future<void> onLogin({
    required AuthProvider authProvider,
    required String username,
    required String password,
    required Function onSuccess,
    required Function(String) onFailure
  }) async {

    Result res = await authProvider.login(
      username,
      password
    );

    if (res.success){
      // await context.read<DevicesProvider>().fetchDevices();
      onSuccess();
    } else {
      onFailure(res.error!);
    }
  }

  static Future<void> onSignup({
    required AuthProvider authProvider,
    required UserCreate newUser,
    required Function onSuccess,
    required Function(String) onFailure
  }) async {
    Result res = await authProvider.signUp(newUser);
    
    if (res.success) {
      onSuccess();
    } else {
      onFailure(res.error!);
    }
  }

  static Future<void> onUpdate({
    required AuthProvider authProvider,
    required String username,
    required String appleId,
    required String appleIdPassword,
    required Function onSuccess,
    required Function(String) onFailure
  }) async {
    Result res = await authProvider.updateProfile(
      authProvider.user!.id, 
      username,
      appleId, 
      appleIdPassword
    );

    if (res.success) {
      onSuccess();
      await authProvider.refreshUser();
    } else {
      onFailure(res.error!);
    }
  }

  static Future<void> onValidateAppleAccount({
    required AuthProvider authProvider,
    required BuildContext context
  }) async {
    Result<AppleLoginState> res = await authProvider.validateAppleCredentials();
    // print(res.data);
    checkAppleLoginState(context, res);
  }
}

class DeviceHandlers {
  static Future<void> onAddDevice({
    required DevicesProvider devicesProvider,
    required DeviceCreate? device,
    required Function(String) onFailure
  }) async {
    if (device == null) {
      return;
    }

    Result res = await devicesProvider.createDevice(device);

    if (res.success) {
      await devicesProvider.fetchDevices();
    } else {
      onFailure(res.error!);
    }
  }
}