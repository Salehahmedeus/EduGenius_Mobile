import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/storage/token_storage.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  // Login
  Future<bool> login(String email, String password) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        await TokenStorage.saveToken(token);
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Login failed';
    }
  }

  // Send OTP
  Future<void> sendOtp(String email) async {
    try {
      await _client.dio.post(ApiEndpoints.sendOtp, data: {'email': email});
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Failed to send OTP';
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.verifyOtp,
        data: {'email': email, 'otp': otp},
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        await TokenStorage.saveToken(token);
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Invalid OTP';
    }
  }
}
