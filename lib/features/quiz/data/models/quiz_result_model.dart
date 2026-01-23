/// Model for individual question result details
class QuestionResultDetail {
  final int questionId;
  final String questionText;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String? explanation;

  QuestionResultDetail({
    required this.questionId,
    required this.questionText,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    this.explanation,
  });

  factory QuestionResultDetail.fromJson(Map<String, dynamic> json) {
    return QuestionResultDetail(
      questionId: json['question_id'] is String
          ? int.tryParse(json['question_id']) ?? 0
          : (json['question_id'] ?? json['id'] ?? 0),
      questionText: json['question_text'] ?? json['question'] ?? '',
      userAnswer:
          json['user_answer'] ??
          json['selected_option'] ??
          json['selected_answer'] ??
          '',
      correctAnswer: json['correct_answer']?.toString() ?? '',
      isCorrect: json['is_correct'] ?? false,
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'question_text': questionText,
      'user_answer': userAnswer,
      'correct_answer': correctAnswer,
      'is_correct': isCorrect,
      'explanation': explanation,
    };
  }
}

/// Model representing quiz submission result
class QuizResultModel {
  final int quizId;
  final double score;
  final int totalQuestions;
  final int correctAnswers;
  final String? feedback;
  final List<QuestionResultDetail> details;

  QuizResultModel({
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    this.feedback,
    this.details = const [],
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    List<QuestionResultDetail> detailsList = [];
    final detailsData =
        json['attempt_details'] ??
        json['details'] ??
        json['questions'] ??
        json['results'];
    if (detailsData is List) {
      detailsList = detailsData
          .whereType<Map<String, dynamic>>()
          .map(QuestionResultDetail.fromJson)
          .toList();
    } else if (detailsData is Map) {
      detailsList = detailsData.values
          .whereType<Map<String, dynamic>>()
          .map(QuestionResultDetail.fromJson)
          .toList();
    }

    return QuizResultModel(
      quizId: json['quiz_id'] is String
          ? int.tryParse(json['quiz_id']) ?? 0
          : (json['quiz_id'] ?? 0),
      score: json['score'] is String
          ? double.tryParse(json['score']) ?? 0
          : (json['score'] ?? 0).toDouble(),
      totalQuestions: json['total_questions'] ?? detailsList.length,
      correctAnswers: json['correct_answers'] ?? 0,
      feedback: json['feedback'],
      details: detailsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quiz_id': quizId,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'feedback': feedback,
      'details': details.map((d) => d.toJson()).toList(),
    };
  }

  /// Get score as percentage string
  String get scorePercentage => '${score.toStringAsFixed(0)}%';

  /// Get score ratio (e.g., "4/5")
  String get scoreRatio => '$correctAnswers/$totalQuestions';
}
