class Result<T> {
  T? data;
  String? error;

  bool get success => error == null;

  Result.success(this.data);
  Result.failure({required this.error});
}