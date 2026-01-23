import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../data/models/dashboard_home_model.dart';
import '../../data/models/dashboard_stats_model.dart';
import '../../data/services/dashboard_service.dart';
import '../../../../core/constants/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  DashboardHomeModel? _homeData;
  DashboardStatsModel? _statsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      // Load both in parallel
      final homeFuture = _dashboardService.getDashboardHome();
      final statsFuture = _dashboardService.getDashboardStats();

      final results = await Future.wait([homeFuture, statsFuture]);

      if (mounted) {
        setState(() {
          _homeData = results[0] as DashboardHomeModel;
          _statsData = results[1] as DashboardStatsModel;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // Fallback: Try loading just home if stats fail or vice versa,
        // but for now simple error handling
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading dashboard: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Iconsax.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _homeData == null
          ? const Center(child: Text("Failed to load data"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(),
                  const SizedBox(height: 32),

                  // Progress Overview
                  Text(
                    'Overview',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProgressCards(),
                  const SizedBox(height: 32),

                  // Recommendation
                  if (_homeData!.recommendation.hasRecommendation) ...[
                    _buildRecommendationCard(),
                    const SizedBox(height: 32),
                  ],

                  // Stats Section Content
                  if (_statsData != null) ...[
                    // Insights
                    if (_statsData!.insights.isNotEmpty) ...[
                      Text(
                        'AI Insights',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInsightsList(),
                      const SizedBox(height: 32),
                    ],

                    // Performance Trend Chart
                    Text(
                      'Performance Trend',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPerformanceChart(),
                    const SizedBox(height: 32),

                    // Topic Strengths
                    Text(
                      'Topic Strengths',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTopicStrengthChart(),
                    const SizedBox(height: 32),
                  ],

                  // Report Button
                  _buildReportButton(context),
                  // Add extra padding at bottom
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildGreeting() {
    final user = _homeData!.user;
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primary,
          child: Text(
            user.avatarInitials,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.getTextSecondary(context),
              ),
            ),
            Text(
              user.name,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressCards() {
    final progress = _homeData!.progress;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Quizzes',
            '${progress.quizCount}',
            Iconsax.task_square,
            AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Avg Score',
            '${progress.averageScore.toStringAsFixed(0)}%',
            Iconsax.chart_21,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Uploaded',
            '${progress.uploadedCount}',
            Iconsax.document_upload,
            AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.getBorder(context).withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    final rec = _homeData!.recommendation;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primaryMedium.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.magic_star,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI Recommendation',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  rec.text,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: AppColors.getTextPrimary(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsList() {
    return Column(
      children: _statsData!.insights.map((insight) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Iconsax.lamp_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  insight,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.getTextPrimary(context),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPerformanceChart() {
    if (_statsData == null || _statsData!.charts.performanceTrend.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'No performance data',
            style: GoogleFonts.outfit(
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ),
      );
    }

    final points = _statsData!.charts.performanceTrend
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.avgScore))
        .toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.only(right: 20, top: 20, bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.getBorder(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ), // Hide date labels for simplicity
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: points,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicStrengthChart() {
    if (_statsData == null || _statsData!.charts.topicStrengths.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'No topic data',
            style: GoogleFonts.outfit(
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ),
      );
    }

    final topics = _statsData!.charts.topicStrengths;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.getBorder(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.isDark(context)
                  ? AppColors.darkItem
                  : AppColors.black,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${topics[groupIndex].topic}\n',
                  TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '${rod.toY.round()}%',
                      style: TextStyle(
                        color: AppColors.primary, // tooltip text color
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < topics.length) {
                    // Truncate topic name
                    String name = topics[index].topic;
                    if (name.length > 5) name = '${name.substring(0, 5)}...';
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        name,
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: topics.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.avgScore,
                  color: e.value.avgScore >= 80
                      ? AppColors.success
                      : (e.value.avgScore >= 60
                            ? AppColors.warning
                            : AppColors.error),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 100,
                    color: AppColors.getBorder(context).withOpacity(0.3),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () async {
          // Generate Report Logic
          try {
            await _dashboardService.generateReport();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report generated successfully')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to generate report: $e')),
              );
            }
          }
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.getBorder(context)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.document_download, size: 20),
            const SizedBox(width: 8),
            Text(
              'Generate Progress Report',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
