import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/constants/app_colors.dart';

import '../../data/models/quiz_model.dart';
import '../../data/models/quiz_result_model.dart';
import 'quiz_review_screen.dart';
import '../../../../core/widgets/custom_app_bar.dart';

/// Screen displaying quiz results with score and feedback
class QuizResultScreen extends StatelessWidget {
  final QuizResultModel result;
  final QuizModel quiz;

  const QuizResultScreen({super.key, required this.result, required this.quiz});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scorePercent = result.score / 100;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: CustomAppBar(
        title: 'quiz_results'.tr(),
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.home),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // Result header
              _buildResultHeader(context, colorScheme),
              SizedBox(height: 40.h),

              // Score Circle
              _buildScoreCircle(context, colorScheme, scorePercent),
              SizedBox(height: 32.h),

              // Score details
              _buildScoreDetails(context, colorScheme),
              SizedBox(height: 32.h),

              // AI Feedback
              _buildFeedbackCard(context, colorScheme),
              SizedBox(height: 32.h),

              // Action buttons
              _buildActionButtons(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader(BuildContext context, ColorScheme colorScheme) {
    final isGreatScore = result.score >= 80;
    final isGoodScore = result.score >= 60;

    IconData icon;
    Color iconColor;
    String title;
    String subtitle;

    if (isGreatScore) {
      icon = Iconsax.medal_star5;
      iconColor = AppColors.warning; // amber-like
      title = 'excellent'.tr();
      subtitle = 'mastered_msg'.tr();
    } else if (isGoodScore) {
      icon = Iconsax.like_15;
      iconColor = AppColors.success;
      title = 'good_job'.tr();
      subtitle = 'good_work_msg'.tr();
    } else {
      icon = Iconsax.book_1;
      iconColor = AppColors.info;
      title = 'keep_learning'.tr();
      subtitle = 'try_again_msg'.tr();
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 48.r),
        ),
        SizedBox(height: 16.h),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: GoogleFonts.outfit(
            fontSize: 16.sp,
            color: AppColors.getTextSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCircle(
    BuildContext context,
    ColorScheme colorScheme,
    double scorePercent,
  ) {
    Color progressColor;
    if (result.score >= 80) {
      progressColor = AppColors.success;
    } else if (result.score >= 60) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.error;
    }

    return CircularPercentIndicator(
      radius: 100.r,
      lineWidth: 12.w,
      percent: scorePercent.clamp(0.0, 1.0),
      animation: true,
      animationDuration: 1200,
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: progressColor,
      backgroundColor: AppColors.getSurface(context),
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            result.scorePercentage,
            style: GoogleFonts.outfit(
              fontSize: 42.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          Text(
            'score'.tr(),
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDetails(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            icon: Iconsax.tick_circle,
            label: 'correct'.tr(),
            value: '${result.correctAnswers}',
            color: AppColors.success,
            colorScheme: colorScheme,
            context: context,
          ),
          Container(
            height: 50,
            width: 1,
            color: AppColors.grey.withOpacity(0.2),
          ),
          _buildStatItem(
            icon: Iconsax.close_circle,
            label: 'incorrect'.tr(),
            value: '${result.totalQuestions - result.correctAnswers}',
            color: AppColors.error,
            colorScheme: colorScheme,
            context: context,
          ),
          Container(
            height: 50,
            width: 1,
            color: AppColors.grey.withOpacity(0.2),
          ),
          _buildStatItem(
            icon: Iconsax.document_text,
            label: 'total'.tr(),
            value: '${result.totalQuestions}',
            color: AppColors.primary,
            colorScheme: colorScheme,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ColorScheme colorScheme,
    required BuildContext context,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.r),
        SizedBox(height: 8.h),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12.sp,
            color: AppColors.getTextSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(BuildContext context, ColorScheme colorScheme) {
    if (result.feedback == null || result.feedback!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Iconsax.magic_star,
                  color: AppColors.primary,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'ai_feedback'.tr(),
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            result.feedback!,
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              color: AppColors.getTextPrimary(context).withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        // Review Answers Button
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      QuizReviewScreen(result: result, quiz: quiz),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.eye, size: 20.r),
                SizedBox(width: 8.w),
                Text(
                  'review_answers'.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // Back to Home Button
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: OutlinedButton(
            onPressed: () {
              // Pop until we reach the home screen
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.grey.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.home, size: 20.r),
                SizedBox(width: 8.w),
                Text(
                  'back_to_home'.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
