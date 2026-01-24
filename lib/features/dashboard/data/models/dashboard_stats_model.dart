class DashboardStatsModel {
  final StatsSummary summary;
  final StatsCharts charts;
  final List<String> insights;

  DashboardStatsModel({
    required this.summary,
    required this.charts,
    required this.insights,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      summary: StatsSummary.fromJson(json['summary'] ?? {}),
      charts: StatsCharts.fromJson(json['charts'] ?? {}),
      insights: json['insights'] != null
          ? List<String>.from(json['insights'])
          : [],
    );
  }
}

class StatsSummary {
  final int totalQuizzes;
  final double avgScore;
  final int totalStudySessions;

  StatsSummary({
    required this.totalQuizzes,
    required this.avgScore,
    required this.totalStudySessions,
  });

  factory StatsSummary.fromJson(Map<String, dynamic> json) {
    return StatsSummary(
      totalQuizzes: json['total_quizzes'] ?? 0,
      avgScore: json['avg_score'] is String
          ? double.tryParse(json['avg_score']) ?? 0.0
          : (json['avg_score'] ?? 0).toDouble(),
      totalStudySessions: json['total_study_sessions'] ?? 0,
    );
  }
}

class StatsCharts {
  final List<PerformanceTrend> performanceTrend;
  final List<TopicStrength> topicStrengths;
  final List<dynamic> activityBreakdown;

  StatsCharts({
    required this.performanceTrend,
    required this.topicStrengths,
    required this.activityBreakdown,
  });

  factory StatsCharts.fromJson(Map<String, dynamic> json) {
    return StatsCharts(
      performanceTrend:
          (json['performance_trend'] as List?)
              ?.map((e) => PerformanceTrend.fromJson(e))
              .toList() ??
          [],
      topicStrengths:
          (json['topic_strengths'] as List?)
              ?.map((e) => TopicStrength.fromJson(e))
              .toList() ??
          [],
      activityBreakdown: json['activity_breakdown'] ?? [],
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
      avgScore: json['avg_score'] is String
          ? double.tryParse(json['avg_score']) ?? 0.0
          : (json['avg_score'] ?? 0).toDouble(),
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
      avgScore: json['avg_score'] is String
          ? double.tryParse(json['avg_score']) ?? 0.0
          : (json['avg_score'] ?? 0).toDouble(),
    );
  }
}
