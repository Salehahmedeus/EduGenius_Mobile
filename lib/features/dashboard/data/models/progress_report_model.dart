class ProgressReportModel {
  final int userId;
  final int totalQuizzes;
  final double averageScore;
  final List<String> topicsStudied;
  final List<String> strengths;
  final List<String> weaknesses;
  final DateTime generatedAt;

  ProgressReportModel({
    required this.userId,
    required this.totalQuizzes,
    required this.averageScore,
    required this.topicsStudied,
    required this.strengths,
    required this.weaknesses,
    required this.generatedAt,
  });

  factory ProgressReportModel.fromJson(Map<String, dynamic> json) {
    return ProgressReportModel(
      userId: json['user_id'] ?? 0,
      totalQuizzes: json['total_quizzes'] ?? 0,
      averageScore: json['average_score'] is String
          ? double.tryParse(json['average_score']) ?? 0.0
          : (json['average_score'] ?? 0).toDouble(),
      topicsStudied: List<String>.from(json['topics_studied'] ?? []),
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      generatedAt:
          DateTime.tryParse(json['generated_at'] ?? '') ?? DateTime.now(),
    );
  }
}
