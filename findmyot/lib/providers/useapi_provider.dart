import 'package:findmyot/services/api_service.dart';

class Result {
  String? error;

  bool get success => error == null;

  Result.success();
  Result.error({required this.error});
}

abstract class UseapiProvider {
  final ApiService apiService;
  
  UseapiProvider({required this.apiService});
}