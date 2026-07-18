import 'package:dio/dio.dart';
import 'package:findmyot/models/device.dart';

const String BASE_URL = String.fromEnvironment("API_URL");

class ApiResult<T> {
  T? data;
  String? error;

  bool get success => error == null;

  ApiResult.success(this.data);
  ApiResult.failure(this.error);
}

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

  ApiResult _handleError(DioExceptionType type){
    switch (type) {
      case DioExceptionType.connectionError:
        return ApiResult.failure("Connection Error");
      case DioExceptionType.connectionTimeout:
        return ApiResult.failure("Connection timeout");
      case DioExceptionType.sendTimeout:
        return ApiResult.failure("Send Timeout");
      case DioExceptionType.receiveTimeout:
        return ApiResult.failure("Receive Timeout");
      case DioExceptionType.badCertificate:
        return ApiResult.failure("Bad Certificate");
      case DioExceptionType.badResponse:
        return ApiResult.failure("Bad Response");
      case DioExceptionType.cancel:
        return ApiResult.failure("Cancel");
      case DioExceptionType.unknown:
        return ApiResult.failure("Unknown");
      case DioExceptionType.transformTimeout:
        return ApiResult.failure("Transform Timeout");
    }
  } 

  Future<ApiResult> loginForToken(String username, String password) async {
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
      return _handleError(e.type);
    }
    // print(response.data);
    authToken = response.data["access_token"];
    return ApiResult.success(response.data);
  }
  
  Future<ApiResult> getCurrentUser() async {
    Response? response;
    try {
      response = await _http.get(
        "/api/users/me"
      );
    } on DioException catch (e) {
      return _handleError(e.type);
    }

    return ApiResult.success(response.data);
  }

  Future<List<Device>> fetchDevices() async {
    return [];
  } 
}