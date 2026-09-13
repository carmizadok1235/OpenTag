import 'package:findmyot/providers/auth_provider.dart';
import "package:findmyot/models/user.dart";
import 'package:findmyot/models/result.dart';

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
}