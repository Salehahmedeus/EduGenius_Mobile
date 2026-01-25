import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/token_storage.dart';
import '../../main.dart'; // To access navigatorKey
import '../../routes.dart';
import 'package:easy_localization/easy_localization.dart';

class ApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  ApiClient() {
    // Add Interceptor to attach Token to every request
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add Accept-Language header
          final context = navigatorKey.currentContext;
          if (context != null) {
            options.headers['Accept-Language'] = context.locale.languageCode;
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Handle 401 Unauthorized globally: Clear token and redirect to Login/Welcome
            await TokenStorage.deleteToken();
            navigatorKey.currentState?.pushNamedAndRemoveUntil(
              Routes.welcome,
              (route) => false,
            );
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
