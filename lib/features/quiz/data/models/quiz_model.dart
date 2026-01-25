import 'package:easy_localization/easy_localization.dart';
import 'question_model.dart';
import 'quiz_result_model.dart';

/// Status enum for quiz state
enum QuizStatus { pending, completed }

/// Model representing a quiz with its questions
class QuizModel {
  final int id;
  final String topic;
  final int difficulty; // 1=Easy, 2=Medium, 3=Hard
  final QuizStatus status;
  final double? score;
  final List<QuestionModel> questions;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final QuizResultModel? result;

  QuizModel({
    required this.id,
    required this.topic,
    required this.difficulty,
    this.status = QuizStatus.pending,
    this.score,
    this.questions = const [],
    this.createdAt,
    this.completedAt,
    this.result,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    // Guard against non-map inputs
    if (json.isEmpty) {
      return QuizModel(id: 0, topic: '', difficulty: 1, questions: const []);
    }

    // Parse status string to enum
    QuizStatus quizStatus = QuizStatus.pending;
    if (json['status'] != null) {
      final statusValue = json['status'].toString().toLowerCase();
      quizStatus = statusValue == 'completed'
          ? QuizStatus.completed
          : QuizStatus.pending;
    } else if (json['is_completed'] != null) {
      final completed = json['is_completed'];
      final isDone = completed == true || completed == 1 || completed == '1';
      quizStatus = isDone ? QuizStatus.completed : QuizStatus.pending;
    }

    // Parse questions list; backend may send list or map
    final questionsList = _parseQuestions(
      json['questions'] ?? json['quiz_questions'],
    );

    return QuizModel(
      id: json['id'] is String
          ? int.tryParse(json['id']) ?? 0
          : (json['id'] ?? 0),
      topic: json['topic']?.toString() ?? '',
      difficulty: json['difficulty'] is String
          ? int.tryParse(json['difficulty']) ?? 1
          : (json['difficulty'] ?? 1),
      status: quizStatus,
      score: json['score'] is String
          ? double.tryParse(json['score'])
          : (json['score']?.toDouble()),
      questions: questionsList,
      createdAt: _parseDate(json['created_at']),
      completedAt: _parseDate(json['completed_at']),
      result: json['result'] != null
          ? QuizResultModel.fromJson(Map<String, dynamic>.from(json['result']))
          : null,
    );
  }

  static List<QuestionModel> _parseQuestions(dynamic questionsData) {
    if (questionsData is List) {
      return questionsData
          .map((q) {
            if (q is Map) {
              return QuestionModel.fromJson(Map<String, dynamic>.from(q));
            }
            return null;
          })
          .whereType<QuestionModel>()
          .toList();
    }

    if (questionsData is Map) {
      return questionsData.values
          .map((q) {
            if (q is Map) {
              return QuestionModel.fromJson(Map<String, dynamic>.from(q));
            }
            return null;
          })
          .whereType<QuestionModel>()
          .toList();
    }

    return [];
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic': topic,
      'difficulty': difficulty,
      'status': status == QuizStatus.completed ? 'completed' : 'pending',
      'score': score,
      'questions': questions.map((q) => q.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'result': result?.toJson(),
    };
  }

  /// Get difficulty label
  String get difficultyLabel {
    switch (difficulty) {
      case 1:
        return 'easy'.tr();
      case 2:
        return 'medium'.tr();
      case 3:
        return 'hard'.tr();
      default:
        return 'easy'.tr();
    }
  }

  /// Check if quiz is completed
  bool get isCompleted => status == QuizStatus.completed;
}
