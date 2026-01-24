import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'error_loading_dashboard'.tr()}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: Text(
          'dashboard'.tr(),
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _homeData == null
          ? Center(child: Text("failed_to_load_data".tr()))
          : LiquidPullToRefresh(
              onRefresh: _loadData,
              color: AppColors.primary,
              backgroundColor: AppColors.getSurface(context),
              showChildOpacityTransition: false,
              springAnimationDurationInMilliseconds: 500,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.r),
                physics:
                    const AlwaysScrollableScrollPhysics(), // Required for pull to refresh
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(),
                    SizedBox(height: 32.h),

                    // Progress Overview
                    Text(
                      'overview'.tr(),
                      style: GoogleFonts.outfit(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildProgressCards(),
                    SizedBox(height: 32.h),

                    // Recommendation
                    if (_homeData!.recommendation.hasRecommendation) ...[
                      _buildRecommendationCard(),
                      SizedBox(height: 32.h),
                    ],

                    // Stats Section Content
                    if (_statsData != null) ...[
                      // Insights
                      if (_statsData!.insights.isNotEmpty) ...[
                        Text(
                          'ai_insights'.tr(),
                          style: GoogleFonts.outfit(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(context),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildInsightsList(),
                        SizedBox(height: 32.h),
                      ],

                      // Performance Trend Chart
                      Text(
                        'performance_trend'.tr(),
                        style: GoogleFonts.outfit(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildPerformanceChart(),
                      SizedBox(height: 32.h),

                      // Topic Strengths
                      Text(
                        'topic_strengths'.tr(),
                        style: GoogleFonts.outfit(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildTopicStrengthChart(),
                      SizedBox(height: 32.h),
                    ],

                    // Report Button
                    _buildReportButton(context),
                    // Add extra padding at bottom
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGreeting() {
    final user = _homeData!.user;
    return Row(
      children: [
        CircleAvatar(
          radius: 30.r,
          backgroundColor: AppColors.primary,
          child: Text(
            user.avatarInitials,
            style: GoogleFonts.outfit(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'welcome_back'.tr(),
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: AppColors.getTextSecondary(context),
              ),
            ),
            Text(
              user.name,
              style: GoogleFonts.outfit(
                fontSize: 24.sp,
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
            'quizzes'.tr(),
            '${progress.quizCount}',
            Iconsax.task_square,
            AppColors.info,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            'avg_score_label'.tr(),
            '${progress.averageScore.toStringAsFixed(0)}%',
            Iconsax.chart_21,
            AppColors.success,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            'uploaded'.tr(),
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
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.getBorder(context).withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.r),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
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
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primaryMedium.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
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
                      size: 20.r,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'ai_recommendation'.tr(),
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  rec.text,
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
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
        // Format text: Remove decimals from % and handle **bold**
        String cleanText = insight.replaceAllMapped(
          RegExp(r'(\d+)\.0+%|(\d+\.\d+?)0+%'),
          (match) {
            // If it matches exactly integers like 20.0000%, group(1) might catch 20
            // Ideally just parse the number
            String numStr = match.group(1) ?? match.group(2) ?? '';
            if (numStr.isEmpty) return match.group(0)!;
            // Simple double parse
            double val =
                double.tryParse(match.group(0)!.replaceAll('%', '')) ?? 0;
            return '${val.toStringAsFixed(0)}%';
          },
        );

        // Better Regex for 20.0000% specifically as mentioned by user
        cleanText = cleanText.replaceAllMapped(RegExp(r'(\d+\.\d+)%'), (match) {
          double val = double.tryParse(match.group(1)!) ?? 0;
          return '${val.toStringAsFixed(0)}%';
        });

        List<InlineSpan> spans = [];
        final boldRegex = RegExp(r'\*\*(.*?)\*\*');
        int lastIndex = 0;

        for (final match in boldRegex.allMatches(cleanText)) {
          if (match.start > lastIndex) {
            spans.add(
              TextSpan(
                text: cleanText.substring(lastIndex, match.start),
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  color: AppColors.getTextPrimary(context),
                  height: 1.5,
                ),
              ),
            );
          }
          spans.add(
            TextSpan(
              text: match.group(1),
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color:
                    AppColors.primary, // Highlight bold text with primary color
                height: 1.5,
              ),
            ),
          );
          lastIndex = match.end;
        }

        if (lastIndex < cleanText.length) {
          spans.add(
            TextSpan(
              text: cleanText.substring(lastIndex),
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: AppColors.getTextPrimary(context),
                height: 1.5,
              ),
            ),
          );
        }

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Iconsax.magic_star,
                  color: AppColors.primary,
                  size: 18.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: RichText(text: TextSpan(children: spans)),
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
            'no_performance_data'.tr(),
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
      height: 250.h,
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 24.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.getBorder(context).withOpacity(0.5),
        ),
        boxShadow: [
          if (!AppColors.isDark(context))
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.getBorder(context).withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  // Show only start and end date labels if too many points?
                  // For now, let's just show indices or keep simple
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (points.length - 1).toDouble() + 0.1, // Add slight padding
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: points,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.white,
                    strokeWidth: 2,
                    strokeColor: AppColors.primary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.primary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => AppColors.getSurface(context),
              tooltipBorder: BorderSide(
                color: AppColors.primary.withOpacity(0.2),
              ),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  return LineTooltipItem(
                    '${touchedSpot.y.toInt()}%',
                    TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  );
                }).toList();
              },
            ),
          ),
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
            'no_topic_data'.tr(),
            style: GoogleFonts.outfit(
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ),
      );
    }

    final topics = _statsData!.charts.topicStrengths;

    return Container(
      height: 320.h,
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.getBorder(context).withOpacity(0.5),
        ),
        boxShadow: [
          if (!AppColors.isDark(context))
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
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
              getTooltipColor: (_) => AppColors.getSurface(context),
              tooltipBorder: BorderSide(
                color: AppColors.primary.withOpacity(0.2),
              ),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String topicName = topics[groupIndex].topic;
                return BarTooltipItem(
                  '$topicName\n',
                  TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '${rod.toY.round()}%',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
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
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < topics.length) {
                    // Truncate topic name smart
                    String name = topics[index].topic;
                    if (name.length > 8) name = '${name.substring(0, 8)}...';
                    return Padding(
                      padding: EdgeInsets.only(top: 10.0.h),
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Text(
                          name,
                          style: TextStyle(
                            color: AppColors.getTextSecondary(context),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
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
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.getBorder(context).withOpacity(0.3),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: topics.asMap().entries.map((e) {
            Color barColor = e.value.avgScore >= 80
                ? AppColors.success
                : (e.value.avgScore >= 60
                      ? AppColors.warning
                      : AppColors.error);
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.avgScore,
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [barColor.withOpacity(0.7), barColor],
                  ),
                  width: 16.w,
                  borderRadius: BorderRadius.all(Radius.circular(6.r)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 100,
                    color: AppColors.getBackground(
                      context,
                    ).withOpacity(0.5), // cleaner background
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
      height: 56.h,
      child: OutlinedButton(
        onPressed: () async {
          // Generate Report Logic
          try {
            final report = await _dashboardService.generateReport();
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.getSurface(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Row(
                    children: [
                      Icon(Iconsax.document_text, color: AppColors.primary),
                      SizedBox(width: 12.w),
                      Text(
                        'progress_report'.tr(),
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'overview'.tr(),
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Total Quizzes: ${report.totalQuizzes}',
                          style: GoogleFonts.outfit(
                            color: AppColors.getTextPrimary(context),
                          ),
                        ),
                        Text(
                          'Average Score: ${report.averageScore.toStringAsFixed(1)}%',
                          style: GoogleFonts.outfit(
                            color: AppColors.getTextPrimary(context),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        if (report.strengths.isNotEmpty) ...[
                          Text(
                            'Strengths',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          ...report.strengths.map(
                            (s) => Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: AppColors.success,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    s,
                                    style: GoogleFonts.outfit(
                                      fontSize: 12.sp,
                                      color: AppColors.getTextSecondary(
                                        context,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
                        ],

                        if (report.weaknesses.isNotEmpty) ...[
                          Text(
                            'Areas for Improvement',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          ...report.weaknesses.map(
                            (w) => Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 16,
                                  color: AppColors.warning,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    w,
                                    style: GoogleFonts.outfit(
                                      fontSize: 12.sp,
                                      color: AppColors.getTextSecondary(
                                        context,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
                        ],

                        Text(
                          'Generated: ${report.generatedAt.toString().split('.')[0]}',
                          style: GoogleFonts.outfit(
                            fontSize: 10.sp,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: GoogleFonts.outfit(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
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
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.document_download, size: 20.r),
            SizedBox(width: 8.w),
            Text(
              'Generate Progress Report',
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
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
