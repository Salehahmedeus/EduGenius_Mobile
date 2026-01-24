import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  // Login
  Future<bool> login(String email, String password) async {
    final fullUrl = '${_client.dio.options.baseUrl}${ApiEndpoints.login}';
    print("Attempting login to: $fullUrl");
    try {
      final response = await _client.dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      print("Response: ${response.statusCode} - ${response.data}");

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        await TokenStorage.saveToken(token);
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("Login Error: ${e.message}");
      if (e.response != null) {
        print("Server Data: ${e.response?.data}");
      }

      throw e.response?.data['error'] ?? 'Login failed';
    }
  }

  // Register
  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password, // Usually required by Laravel
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final token = response.data['access_token'];
        await TokenStorage.saveToken(token);
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw e.response?.data['message'] ??
          e.response?.data['error'] ??
          'Registration failed';
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

  // Logout
  Future<void> logout() async {
    try {
      await _client.dio.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) {
        throw e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Logout failed';
      }
    } finally {
      await TokenStorage.deleteToken();
    }
  }

  // Get Profile
  Future<UserModel> getProfile() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.profile);
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
      throw 'Failed to load profile';
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to load profile';
    }
  }
}
