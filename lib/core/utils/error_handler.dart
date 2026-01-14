import 'package:dio/dio.dart';

class ErrorHandler {
  static String parse(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Connection timed out. Please check your internet.";
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return "Session expired. Please login again.";
          } else if (statusCode == 403) {
            return "You don't have permission to perform this action.";
          } else if (statusCode == 404) {
            return "Resource not found.";
          } else if (statusCode == 500) {
            return "Server error. Please try again later.";
          }
          return error.response?.data?['message'] ??
              error.response?.data?['error'] ??
              "Internal server error ($statusCode)";
        case DioExceptionType.cancel:
          return "Request cancelled.";
        case DioExceptionType.connectionError:
          return "No internet connection.";
        case DioExceptionType.unknown:
          if (error.message?.contains('SocketException') ?? false) {
            return "No internet connection.";
          }
          return "An unexpected error occurred.";
        default:
          return "Something went wrong.";
      }
    }
    return error.toString();
  }
}
