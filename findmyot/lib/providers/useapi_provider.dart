import 'package:findmyot/services/api_service.dart';


abstract class UseapiProvider {
  final ApiService apiService;
  
  UseapiProvider({required this.apiService});
}