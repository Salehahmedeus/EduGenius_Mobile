import 'question_model.dart';

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

  QuizModel({
    required this.id,
    required this.topic,
    required this.difficulty,
    this.status = QuizStatus.pending,
    this.score,
    this.questions = const [],
    this.createdAt,
    this.completedAt,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    // Parse status string to enum
    QuizStatus quizStatus = QuizStatus.pending;
    if (json['status'] != null) {
      quizStatus = json['status'] == 'completed'
          ? QuizStatus.completed
          : QuizStatus.pending;
    }

    // Parse questions list
    List<QuestionModel> questionsList = [];
    if (json['questions'] != null) {
      questionsList = (json['questions'] as List)
          .map((q) => QuestionModel.fromJson(q))
          .toList();
    }

    return QuizModel(
      id: json['id'] ?? 0,
      topic: json['topic'] ?? '',
      difficulty: json['difficulty'] ?? 1,
      status: quizStatus,
      score: json['score']?.toDouble(),
      questions: questionsList,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
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
    };
  }

  /// Get difficulty label
  String get difficultyLabel {
    switch (difficulty) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      default:
        return 'Unknown';
    }
  }

  /// Check if quiz is completed
  bool get isCompleted => status == QuizStatus.completed;
}
