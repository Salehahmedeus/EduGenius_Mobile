import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/quiz_model.dart';
import '../models/quiz_result_model.dart';
import '../../../../main.dart';
import 'package:easy_localization/easy_localization.dart';

class QuizService {
  final ApiClient _apiClient = ApiClient();

  /// Generate a new quiz
  Future<QuizModel> generateQuiz({
    required List<int> materialIds,
    required int difficulty,
  }) async {
    try {
      // Explicitly send language code for LLM generation
      final context = navigatorKey.currentContext;
      final language = context?.locale.languageCode ?? 'en';

      final response = await _apiClient.dio.post(
        ApiEndpoints.quizGenerate,
        data: {
          'material_ids': materialIds,
          'difficulty': difficulty,
          'language': language, // Explicitly tell backend which language to use
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic data = response.data;

        // 1. Unwrap the 'data' envelope from Laravel
        if (data is Map && data.containsKey('data')) {
          data = data['data'];
        }

        // 2. Safe casting to Map<String, dynamic>
        // This fixes the specific "type mismatch" error often seen with Dio
        if (data is Map) {
          return QuizModel.fromJson(Map<String, dynamic>.from(data));
        }

        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Invalid JSON format received from server',
        );
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Failed to generate quiz: Status ${response.statusCode}',
      );
    } catch (e) {
      // Print error to console for debugging
      print("Quiz Generation Error: $e");
      rethrow;
    }
  }

  /// Submit quiz answers
  Future<QuizResultModel> submitQuiz({
    required int quizId,
    required Map<int, String> answers,
  }) async {
    try {
      // Convert int keys to string keys for JSON compatibility
      final answersJson = answers.map(
        (key, value) => MapEntry(key.toString(), value),
      );

      // Debug: Print request data
      print("DEBUG submitQuiz: quiz_id = $quizId");
      print("DEBUG submitQuiz: answers = $answersJson");
      print("DEBUG submitQuiz: endpoint = ${ApiEndpoints.quizSubmit}");

      final response = await _apiClient.dio.post(
        ApiEndpoints.quizSubmit, // Make sure this is '/quiz/submit'
        data: {'quiz_id': quizId, 'answers': answersJson},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic data = response.data;

        if (data is Map && data.containsKey('data')) {
          data = data['data'];
        }

        // Add quiz_id manually if missing, needed for UI
        if (data is Map) {
          final safeMap = Map<String, dynamic>.from(data);
          if (!safeMap.containsKey('quiz_id')) {
            safeMap['quiz_id'] = quizId;
          }
          return QuizResultModel.fromJson(safeMap);
        }
      }
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Failed to submit quiz',
      );
    } on DioException catch (e) {
      print("Quiz Submission DioException: ${e.type}");
      print("Quiz Submission Error Message: ${e.message}");
      print("Quiz Submission Response Status: ${e.response?.statusCode}");
      print("Quiz Submission Response Data: ${e.response?.data}");
      rethrow;
    } catch (e) {
      print("Quiz Submission Error: $e");
      rethrow;
    }
  }

  /// Get quiz history
  Future<List<QuizModel>> getHistory() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.quizHistory);

      if (response.statusCode == 200) {
        dynamic rawData = response.data;

        // 1. Handle if Laravel wraps it in { "data": [...] }
        if (rawData is Map && rawData.containsKey('data')) {
          rawData = rawData['data'];
        }

        // 2. Handle if it's a direct List [...]
        if (rawData is List) {
          return rawData
              .map(
                (item) => QuizModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
        }

        return [];
      }
      return [];
    } catch (e) {
      print("Get History Error: $e");
      rethrow;
    }
  }

  /// Get full quiz review details (Questions + Result)
  Future<Map<String, dynamic>> getQuizReviewData(int quizId) async {
    try {
      // 👇 ADD THIS PRINT
      print(
        "DEBUG: Requesting URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.quizDetail}/$quizId",
      );

      final response = await _apiClient.dio.get(
        '${ApiEndpoints.quizDetail}/$quizId',
      );

      if (response.statusCode == 200) {
        // 👇 ADD THIS PRINT
        print("DEBUG: API Response: ${response.data}");
        return response.data;
      }
      throw DioException(requestOptions: response.requestOptions);
    } on DioException catch (e) {
      // ... keep existing error handling ...
      print(
        "DEBUG: Error ${e.response?.statusCode} - ${e.response?.statusMessage}",
      );
      rethrow;
    }
  }

  /// Get full details of a specific quiz (Used for resuming pending quizzes)
  Future<QuizModel> getQuizDetail(int quizId) async {
    try {
      // Endpoint: GET /api/quiz/{id}
      final response = await _apiClient.dio.get(
        '${ApiEndpoints.quizDetail}/$quizId',
      );

      if (response.statusCode == 200) {
        dynamic data = response.data;

        // Handle Laravel wrapper { "data": ... } if present
        if (data is Map && data.containsKey('data')) {
          data = data['data'];
        }

        // Convert to Model
        return QuizModel.fromJson(Map<String, dynamic>.from(data));
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Failed to load quiz details',
      );
    } catch (e) {
      print("Get Quiz Detail Error: $e");
      rethrow;
    }
  }
}
