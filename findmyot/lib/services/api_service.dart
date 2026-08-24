import 'package:dio/dio.dart';
import 'package:findmyot/models/device.dart';
import 'package:findmyot/models/user.dart';
import 'package:findmyot/models/result.dart';

const String BASE_URL = String.fromEnvironment("API_URL");

// class ApiResult<T> {
//   T? data;
//   String? error;

//   bool get success => error == null;

//   ApiResult.success(this.data);
//   ApiResult.failure({required this.error});
// }

class ApiService {
  final Dio _http = Dio(BaseOptions(
    baseUrl: BASE_URL
  ));

  // final String baseUrl;
  String authToken = "";

  ApiService() {
    _http.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers["Authorization"] = "Bearer $authToken";
        // options.validateStatus = (status) => status! < 500;
        handler.next(options);
      },
      onResponse: (response, handler) {
        print("LOG: ${response.statusCode}");
        handler.next(response);
      },
      // onError: (error, handler) {
      //   print("shlongabong");
      //   throw error;
      //   handler.next(error);
      // },
    ));
  }

  Result _handleError(DioExceptionType type, Response? res){
    dynamic message = "";
    if (res != null) {
      message = res.data;
    }
    switch (type) {
      case DioExceptionType.connectionError:
        return Result.failure(error: "Connection Error");
      case DioExceptionType.connectionTimeout:
        return Result.failure(error: "Connection timeout");
      case DioExceptionType.sendTimeout:
        return Result.failure(error: "Send Timeout");
      case DioExceptionType.receiveTimeout:
        return Result.failure(error: "Receive Timeout");
      case DioExceptionType.badCertificate:
        return Result.failure(error: "Bad Certificate");
      case DioExceptionType.badResponse:
        return Result.failure(error: "Bad Response: $message");
      case DioExceptionType.cancel:
        return Result.failure(error: "Cancel");
      case DioExceptionType.unknown:
        return Result.failure(error: "Unknown");
      case DioExceptionType.transformTimeout:
        return Result.failure(error: "Transform Timeout");
    }
  } 

  Future<Result> loginForToken(String username, String password) async {
    String url = _http.options.baseUrl;
    print("attempting login with $username and $password at $url");
    // do form data not json data
    FormData formData = FormData.fromMap({
      "grant_type": "password" ,
      "username": username,
      "password": password
    });
    Response? response;
    try{
      response = await _http.post(
        "/api/users/token",
        data: formData
      );
    } on DioException catch (e) {
      return _handleError(e.type, e.response);
    }
    // print(response.data);
    authToken = response.data["access_token"];
    return Result.success(response.data);
  }
  
  Future<Result> getCurrentUser() async {
    Response? response;
    try {
      response = await _http.get(
        "/api/users/me"
      );
    } on DioException catch (e) {
      return _handleError(e.type, e.response);
    }

    return Result.success(response.data);
  }

  Future<Result> createUser(UserCreate user) async {
    Response? response;

    try {
      response = await _http.post(
        "/api/users",
        data: {
          "username": user.username,
          "password": user.password,
          "appleid": user.appleid,
          "apple_password": user.appleidPassword
        }
      );
    } on DioException catch (e) {
      return _handleError(e.type, e.response);
    }

    return Result.success(response.data);
  }

  Future<Result> updateUser(
    int userId,
    String? username,
    String? appleId,
    String? appleIdPassword
  ) async {
    Response? response;
    Map data = {};

    if (username != null){
      data.addAll({"username": username});
    }
    if (appleId != null){
      data.addAll({"appleid": appleId});
    }
    if (appleIdPassword != null){
      data.addAll({"apple_password": appleIdPassword});
    }

    try {
      response = await _http.patch(
        "/api/users/$userId",
        data: data
      );
    } on DioException catch (e) {
      return _handleError(e.type, e.response);
    }

    return Result.success(response.data);
  }

  Future<Result> fetchDevices() async {
    Response? response;

    try {
      response = await _http.get(
        "/api/devices"
      );
    } on DioException catch (e) {
      return _handleError(e.type, e.response);
    }

    return Result.success(response.data);
  }

  Future<Result> createDevice(DeviceCreate device) async {
    Response? response;

    try {
      response = await _http.post(
        "/api/devices",
        data: {
          "symmetric_key": device.symmetricKey,
          "private_key": device.privateKey,
          "time_paired": device.timePaired
        }
      );
    } on DioException catch (e) {
      return _handleError(e.type, e.response);
    }

    return Result.success(response.data);
  }

  Future<Result> validateAppleId() async {
    Response? response;

    try {
      response = await _http.get(
        "/api/apple/login"
      );
    } on DioException catch (e) {
      return _handleError(e.type, e.response);
    }

    return Result.success(response.data);
  }

  Future<Result> verifiyCode(String code) async {
    Response? response;

    try {
      response = await _http.post(
        "/api/apple/verify2fa",
        data: {
          "code": code
        }
      );
    } on DioException catch (e) {
      return _handleError(e.type, e.response);
    }

    return Result.success(response.data);
  }
}