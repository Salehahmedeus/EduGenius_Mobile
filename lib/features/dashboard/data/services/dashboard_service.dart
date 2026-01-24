import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/dashboard_home_model.dart';
import '../models/dashboard_stats_model.dart';
import '../models/progress_report_model.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardHomeModel> getDashboardHome() async {
    try {
      print(
        "DEBUG: Fetching dashboard home from: ${ApiEndpoints.dashboardHome}",
      );
      final response = await _apiClient.dio.get(ApiEndpoints.dashboardHome);

      print("DEBUG: Dashboard Home Response Status: ${response.statusCode}");
      print("DEBUG: Dashboard Home Response Data: ${response.data}");

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
    } on DioException catch (e) {
      print("DEBUG: Dashboard Home DioException: ${e.type}");
      print("DEBUG: Dashboard Home Error Message: ${e.message}");
      print("DEBUG: Dashboard Home Response Status: ${e.response?.statusCode}");
      print("DEBUG: Dashboard Home Response Data: ${e.response?.data}");
      rethrow;
    } catch (e) {
      print("DEBUG: Dashboard Home General Error: $e");
      rethrow;
    }
  }

  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      print(
        "DEBUG: Fetching dashboard stats from: ${ApiEndpoints.dashboardStats}",
      );
      final response = await _apiClient.dio.get(ApiEndpoints.dashboardStats);

      print("DEBUG: Dashboard Stats Response Status: ${response.statusCode}");
      print("DEBUG: Dashboard Stats Response Data: ${response.data}");

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
    } on DioException catch (e) {
      print("DEBUG: Dashboard Stats DioException: ${e.type}");
      print("DEBUG: Dashboard Stats Error Message: ${e.message}");
      print(
        "DEBUG: Dashboard Stats Response Status: ${e.response?.statusCode}",
      );
      print("DEBUG: Dashboard Stats Response Data: ${e.response?.data}");
      rethrow;
    } catch (e) {
      print("DEBUG: Dashboard Stats General Error: $e");
      rethrow;
    }
  }

  Future<ProgressReportModel> generateReport() async {
    try {
      print(
        "DEBUG: Generating report (POST) from: ${ApiEndpoints.dashboardReport}",
      );
      // Switch back to POST as GET returned 405
      final response = await _apiClient.dio.post(ApiEndpoints.dashboardReport);

      print("DEBUG: Report Response Status: ${response.statusCode}");
      print("DEBUG: Report Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic data = response.data;

        // Handle Laravel wrapper { "message": "...", "data": ... }
        if (data is Map && data.containsKey('data')) {
          data = data['data'];
        }

        return ProgressReportModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw DioException(requestOptions: response.requestOptions);
    } catch (e) {
      print("DEBUG: Generate Report Error: $e");
      rethrow;
    }
  }
}
