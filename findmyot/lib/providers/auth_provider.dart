import "package:findmyot/providers/useapi_provider.dart";
import "package:findmyot/models/user.dart";
import "package:findmyot/services/api_service.dart";
import "package:flutter/material.dart";


class AuthProvider extends UseapiProvider with ChangeNotifier {
  User? _user;
  String? _authToken;

  AuthProvider({required super.apiService});
  
  // set user(User newUser) {
  //   _user = newUser;
  //   notifyListeners();
  // }
  Future<Result> login(String username, String password) async {

    ApiResult result = await apiService.loginForToken(username, password);
    if (!result.success){
      // print(result.error);
      return Result.error(error: result.error);
    }
    _authToken = result.data["access_token"];
    
    result = await apiService.getCurrentUser();
    if (!result.success) {
      // print(result.error);
      return Result.error(error: result.error);
    }

    _user = User.fromJson(result.data);

    return Result.success();
  }
}