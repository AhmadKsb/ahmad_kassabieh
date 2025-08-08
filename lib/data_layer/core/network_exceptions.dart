import 'package:dio/dio.dart';

/// Converts Dio errors into simple, user-friendly messages.
///
/// Useful for centralising network error handling across the app.
class NetException implements Exception {
  final String message;

  NetException(this.message);

  /// Creates a [NetException] based on the type of [DioException].
  static NetException fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return NetException("Connection timed out.");
      case DioExceptionType.sendTimeout:
        return NetException("Send timed out.");
      case DioExceptionType.receiveTimeout:
        return NetException("Receive timed out.");
      case DioExceptionType.badResponse:
        return NetException("Server error: ${e.response?.statusCode}");
      case DioExceptionType.cancel:
        return NetException("Request cancelled.");
      case DioExceptionType.connectionError:
        return NetException("No internet connection.");
      default:
        return NetException("An unexpected error occurred.");
    }
  }

  @override
  String toString() => message;
}
