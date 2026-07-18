

class HttpException {
  int statusCode;
  String message;

  HttpException({required this.statusCode, required this.message});
}