import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/services/dashboard_service.dart';
import '../widgets/dashboard_greeting.dart';
import '../widgets/dashboard_stats_overview.dart';
import '../widgets/insights_list.dart';
import '../widgets/performance_chart.dart';
import '../widgets/recent_activities_list.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/report_button.dart';
import '../widgets/topic_strength_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  DashboardModel? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (mounted) setState(() => _isLoading = true);

      final data = await _dashboardService.getDashboardHome();

      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
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
      appBar: CustomAppBar(title: 'dashboard'.tr(), showBackButton: false),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _dashboardData == null
            ? Center(child: Text("failed_to_load_data".tr()))
            : LiquidPullToRefresh(
                onRefresh: _loadData,
                color: AppColors.primary,
                backgroundColor: AppColors.getSurface(context),
                showChildOpacityTransition: false,
                springAnimationDurationInMilliseconds: 500,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.r),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardGreeting(user: _dashboardData!.user),
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
                      DashboardStatsOverview(stats: _dashboardData!.stats),
                      SizedBox(height: 32.h),

                      // AI Recommendation - Always show
                      RecommendationCard(
                        recommendation:
                            _dashboardData!.recommendation.hasRecommendation
                            ? _dashboardData!.recommendation
                            : Recommendation(
                                hasRecommendation: true,
                                text:
                                    'Keep up the great work! Complete more quizzes to get personalized AI recommendations.',
                                action: '',
                              ),
                      ),
                      SizedBox(height: 32.h),

                      // AI Insights - Always show
                      Text(
                        'ai_insights'.tr(),
                        style: GoogleFonts.outfit(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      InsightsList(
                        insights: _dashboardData!.insights.isNotEmpty
                            ? _dashboardData!.insights
                            : [
                                'Start by uploading your study materials to get personalized insights',
                                'Take quizzes regularly to track your progress',
                                'Review your quiz results to identify areas for improvement',
                              ],
                      ),
                      SizedBox(height: 32.h),

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
                      PerformanceChart(
                        trends: _dashboardData!.charts.performanceTrend,
                      ),
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
                      TopicStrengthChart(
                        topicStrengths: _dashboardData!.charts.topicStrengths,
                      ),
                      SizedBox(height: 32.h),

                      // Recent Activities
                      if (_dashboardData!.recentActivities.isNotEmpty) ...[
                        Text(
                          'recent_activities'.tr(),
                          style: GoogleFonts.outfit(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(context),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        RecentActivitiesList(
                          activities: _dashboardData!.recentActivities,
                        ),
                        SizedBox(height: 32.h),
                      ],

                      // Report Button
                      ReportButton(
                        onGenerateReport: _dashboardService.generateReport,
                      ),
                      // Add extra padding at bottom
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
