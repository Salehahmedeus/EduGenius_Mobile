class DashboardModel {
  final DashboardUser user;
  final DashboardStats stats;
  final Recommendation recommendation;
  final List<Activity> recentActivities;
  final DashboardCharts charts;
  final List<String> insights;

  DashboardModel({
    required this.user,
    required this.stats,
    required this.recommendation,
    required this.recentActivities,
    required this.charts,
    required this.insights,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      user: DashboardUser.fromJson(json['user'] ?? {}),
      stats: DashboardStats.fromJson(json['stats'] ?? {}),
      recommendation: Recommendation.fromJson(json['recommendation'] ?? {}),
      recentActivities: (json['recent_activities'] as List? ?? [])
          .map((e) => Activity.fromJson(e))
          .toList(),
      charts: DashboardCharts.fromJson(json['charts'] ?? {}),
      insights: List<String>.from(json['insights'] ?? []),
    );
  }
}

class DashboardUser {
  final String name;
  final String avatarInitials;
  final String email;

  DashboardUser({
    required this.name,
    required this.avatarInitials,
    required this.email,
  });

  factory DashboardUser.fromJson(Map<String, dynamic> json) {
    return DashboardUser(
      name: json['name'] ?? '',
      avatarInitials: json['avatar_initials'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class DashboardStats {
  final int uploadedCount;
  final int quizCount;
  final double avgScore;
  final int studySessions;

  DashboardStats({
    required this.uploadedCount,
    required this.quizCount,
    required this.avgScore,
    required this.studySessions,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      uploadedCount: json['uploaded_count'] ?? 0,
      quizCount: json['quiz_count'] ?? 0,
      avgScore: (json['avg_score'] ?? 0).toDouble(),
      studySessions: json['study_sessions'] ?? 0,
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
      action: json['action'] ?? '',
    );
  }
}

class Activity {
  final int id;
  final String title;
  final String type;
  final String timeAgo;

  Activity({
    required this.id,
    required this.title,
    required this.type,
    required this.timeAgo,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      timeAgo: json['time_ago'] ?? '',
    );
  }
}

class DashboardCharts {
  final List<PerformanceTrend> performanceTrend;
  final List<TopicStrength> topicStrengths;
  final List<ActivityBreakdown> activityBreakdown;

  DashboardCharts({
    required this.performanceTrend,
    required this.topicStrengths,
    required this.activityBreakdown,
  });

  factory DashboardCharts.fromJson(Map<String, dynamic> json) {
    return DashboardCharts(
      performanceTrend: (json['performance_trend'] as List? ?? [])
          .map((e) => PerformanceTrend.fromJson(e))
          .toList(),
      topicStrengths: (json['topic_strengths'] as List? ?? [])
          .map((e) => TopicStrength.fromJson(e))
          .toList(),
      activityBreakdown: (json['activity_breakdown'] as List? ?? [])
          .map((e) => ActivityBreakdown.fromJson(e))
          .toList(),
    );
  }
}

class PerformanceTrend {
  final String date;
  final double avgScore;

  PerformanceTrend({required this.date, required this.avgScore});

  factory PerformanceTrend.fromJson(Map<String, dynamic> json) {
    return PerformanceTrend(
      date: json['date'] ?? '',
      avgScore: (json['avg_score'] ?? 0).toDouble(),
    );
  }
}

class TopicStrength {
  final String topic;
  final double avgScore;

  TopicStrength({required this.topic, required this.avgScore});

  factory TopicStrength.fromJson(Map<String, dynamic> json) {
    return TopicStrength(
      topic: json['topic'] ?? '',
      avgScore: (json['avg_score'] ?? 0).toDouble(),
    );
  }
}

class ActivityBreakdown {
  final String activityType;
  final int count;

  ActivityBreakdown({required this.activityType, required this.count});

  factory ActivityBreakdown.fromJson(Map<String, dynamic> json) {
    return ActivityBreakdown(
      activityType: json['activity_type'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}
