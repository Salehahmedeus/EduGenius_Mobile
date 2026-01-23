class DashboardHomeModel {
  final DashboardUser user;
  final DashboardProgress progress;
  final List<dynamic> recentActivities;
  final Recommendation recommendation;

  DashboardHomeModel({
    required this.user,
    required this.progress,
    required this.recentActivities,
    required this.recommendation,
  });

  factory DashboardHomeModel.fromJson(Map<String, dynamic> json) {
    return DashboardHomeModel(
      user: DashboardUser.fromJson(json['user'] ?? {}),
      progress: DashboardProgress.fromJson(json['progress'] ?? {}),
      recentActivities: json['recent_activities'] ?? [],
      recommendation: Recommendation.fromJson(json['recommendation'] ?? {}),
    );
  }
}

class DashboardUser {
  final String name;
  final String avatarInitials;

  DashboardUser({required this.name, required this.avatarInitials});

  factory DashboardUser.fromJson(Map<String, dynamic> json) {
    return DashboardUser(
      name: json['name'] ?? '',
      avatarInitials: json['avatar_initials'] ?? '',
    );
  }
}

class DashboardProgress {
  final int uploadedCount;
  final int quizCount;
  final double averageScore;

  DashboardProgress({
    required this.uploadedCount,
    required this.quizCount,
    required this.averageScore,
  });

  factory DashboardProgress.fromJson(Map<String, dynamic> json) {
    return DashboardProgress(
      uploadedCount: json['uploaded_count'] ?? 0,
      quizCount: json['quiz_count'] ?? 0,
      averageScore: (json['average_score'] ?? 0).toDouble(),
    );
  }
}

class Recommendation {
  final bool hasRecommendation;
  final String text;
  final String action;

  Recommendation({
    required this.hasRecommendation,
    required this.text,
    required this.action,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      hasRecommendation: json['has_recommendation'] ?? false,
      text: json['text'] ?? '',
      action: json['action'] ?? 'none',
    );
  }
}
