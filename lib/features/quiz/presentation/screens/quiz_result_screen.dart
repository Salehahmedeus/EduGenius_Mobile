import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/constants/app_colors.dart';

import '../../data/models/quiz_model.dart';
import '../../data/models/quiz_result_model.dart';
import 'quiz_review_screen.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Result header
              _buildResultHeader(context, colorScheme),
              const SizedBox(height: 40),

              // Score Circle
              _buildScoreCircle(context, colorScheme, scorePercent),
              const SizedBox(height: 32),

              // Score details
              _buildScoreDetails(context, colorScheme),
              const SizedBox(height: 32),

              // AI Feedback
              _buildFeedbackCard(context, colorScheme),
              const SizedBox(height: 32),

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
      title = 'Excellent!';
      subtitle = 'You\'ve mastered this topic!';
    } else if (isGoodScore) {
      icon = Iconsax.like_15;
      iconColor = AppColors.success;
      title = 'Good Job!';
      subtitle = 'Keep up the good work!';
    } else {
      icon = Iconsax.book_1;
      iconColor = AppColors.info;
      title = 'Keep Learning!';
      subtitle = 'Review the material and try again.';
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 48),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.outfit(
            fontSize: 16,
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
      radius: 100,
      lineWidth: 12,
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
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          Text(
            'Score',
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDetails(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            icon: Iconsax.tick_circle,
            label: 'Correct',
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
            label: 'Wrong',
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
            label: 'Total',
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
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Iconsax.magic_star,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Feedback',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.feedback!,
            style: GoogleFonts.outfit(
              fontSize: 14,
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
          height: 56,
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
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.eye, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Review Answers',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Back to Home Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              // Pop until we reach the home screen
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.grey.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.home, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Back to Home',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
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
