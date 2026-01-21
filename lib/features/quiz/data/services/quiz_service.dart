import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/quiz_model.dart';
import '../models/quiz_result_model.dart';

/// Service class for quiz-related API operations
class QuizService {
  final ApiClient _apiClient = ApiClient();

  /// Generate a new quiz based on selected materials and difficulty
  /// [materialIds] - List of material IDs to generate quiz from
  /// [difficulty] - 1=Easy, 2=Medium, 3=Hard
  Future<QuizModel> generateQuiz({
    required List<int> materialIds,
    required int difficulty,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.quizGenerate,
        data: {'material_ids': materialIds, 'difficulty': difficulty},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return QuizModel.fromJson(data);
      }
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Failed to generate quiz',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Submit quiz answers and get results
  /// [quizId] - The ID of the quiz being submitted
  /// [answers] - Map of question ID to selected answer string
  Future<QuizResultModel> submitQuiz({
    required int quizId,
    required Map<int, String> answers,
  }) async {
    try {
      // Convert int keys to string keys for JSON
      final answersJson = answers.map(
        (key, value) => MapEntry(key.toString(), value),
      );

      final response = await _apiClient.dio.post(
        ApiEndpoints.quizSubmit,
        data: {'quiz_id': quizId, 'answers': answersJson},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        // Add quiz_id to the response data if not present
        if (data is Map<String, dynamic> && !data.containsKey('quiz_id')) {
          data['quiz_id'] = quizId;
        }
        return QuizResultModel.fromJson(data);
      }
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Failed to submit quiz',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get quiz history (list of past quizzes)
  Future<List<QuizModel>> getHistory() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.quizHistory);

      if (response.statusCode == 200) {
        final dynamic rawData = response.data;
        List<dynamic> data;

        if (rawData is Map && rawData.containsKey('data')) {
          data = rawData['data'];
        } else if (rawData is List) {
          data = rawData;
        } else {
          return [];
        }

        return data.map((item) => QuizModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get quiz detail by ID
  Future<QuizModel> getQuizDetail(int quizId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiEndpoints.quizDetail}/$quizId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return QuizModel.fromJson(data);
      }
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Failed to get quiz details',
      );
    } catch (e) {
      rethrow;
    }
  }
}
