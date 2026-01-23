import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/dashboard_home_model.dart';
import '../models/dashboard_stats_model.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardHomeModel> getDashboardHome() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.dashboardHome);
      if (response.statusCode == 200) {
        // Handle Laravel wrapping
        dynamic data = response.data;
        if (data is Map && data.containsKey('user')) {
          // It's likely direct object in user example
        }

        // Sometimes Laravel wraps in {data: ...} but user example shows direct object.
        // If it is wrapped:
        if (data is Map && data.containsKey('data')) {
          // But the example structure has "user", "progress" at root?
          // Actually user example:
          // { "user": ..., "progress": ... }
          // So it might be direct. Let's assume direct for now, or check for 'data'.
          if (data['data'] != null &&
              data['data'] is Map &&
              data['data'].containsKey('user')) {
            data = data['data'];
          }
        }

        return DashboardHomeModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw DioException(requestOptions: response.requestOptions);
    } catch (e) {
      rethrow;
    }
  }

  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.dashboardStats);
      if (response.statusCode == 200) {
        dynamic data = response.data;
        if (data is Map && data.containsKey('data')) {
          // Check if 'data' contains 'summary'
          if (data['data'] is Map && data['data'].containsKey('summary')) {
            data = data['data'];
          }
        }
        return DashboardStatsModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw DioException(requestOptions: response.requestOptions);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> generateReport() async {
    try {
      await _apiClient.dio.post(ApiEndpoints.dashboardReport);
    } catch (e) {
      rethrow;
    }
  }
}
