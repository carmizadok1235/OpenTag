import "package:findmyot/providers/useapi_provider.dart";
import "package:findmyot/models/user.dart";
import "package:findmyot/services/api_service.dart";
import "package:findmyot/utils/apple.dart";
import "package:flutter/material.dart";
import 'package:findmyot/models/result.dart';


enum AppleLoginState {
  VERIFIED,
  TWO_FACTOR_AUTH
}

class AuthProvider extends UseapiProvider with ChangeNotifier {
  User? _user;
  String? _authToken;
  bool _appleAccountVerified = false;

  AuthProvider({required super.apiService});
  
  User? get user => _user;
  // set user(User newUser) {
  //   _user = newUser;
  //   notifyListeners();
  // }

  Future<void> refreshUser() async {
    Result result = await apiService.getCurrentUser();
    _user = User.fromJson(result.data);
    notifyListeners();
  }

  Future<Result> login(String username, String password) async {

    Result result = await apiService.loginForToken(username, password);
    if (!result.success) {
      // print(result.error);
      return Result.failure(error: result.error);
    }
    _authToken = result.data["access_token"];
    
    result = await apiService.getCurrentUser();
    if (!result.success) {
      // print(result.error);
      return Result.failure(error: result.error);
    }

    _user = User.fromJson(result.data);

    return Result.success(null);
  }

  Future<Result> signUp(UserCreate? user) async {
    
    if (user == null){
      return Result.failure(error: "User is null");
    }

    Result result = await apiService.createUser(user);
    if (!result.success) {
      return Result.failure(error: result.error);
    }

    return Result.success(null);
  }

  Future<Result> updateProfile(
    int userId,
    String username, 
    String appleId, 
    String appleIdPassword
  ) async {
    Result result = await apiService.updateUser(
      userId,
      username != "" ? username : null, 
      appleId != "" ? appleId : null, 
      appleIdPassword != "" ? appleIdPassword : null
    );

    if (!result.success) {
      return Result.failure(error: result.error);
    }

    return Result.success(null);
  }

  Future<Result<AppleLoginState>> validateAppleCredentials() async {
    Result result = await apiService.validateAppleId();

    return handleAppleVerificationResult(result);
  }

  Future<Result<AppleLoginState>> verifyTwoFactorAuthCode(String code) async {
    Result result = await apiService.verifiyCode(code);
    // if (result.success){
    //   print("api response data is ${result.data}");
    // } else {
    //   print("api error is ${result.error}");
    // }
    return handleAppleVerificationResult(result);
  }
}
