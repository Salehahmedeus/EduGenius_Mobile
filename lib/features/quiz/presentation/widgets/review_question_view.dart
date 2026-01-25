import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/quiz_model.dart';
import '../../data/models/quiz_result_model.dart';
import 'review_answer_option.dart';
import 'review_explanation_card.dart';

class ReviewQuestionView extends StatelessWidget {
  final QuestionResultDetail detail;
  final QuizModel? quizDetail;
  final QuizModel? fallbackQuiz;

  const ReviewQuestionView({
    super.key,
    required this.detail,
    this.quizDetail,
    this.fallbackQuiz,
  });

  @override
  Widget build(BuildContext context) {
    final originalQuestion = (quizDetail ?? fallbackQuiz)?.questions
        .where((q) => q.id == detail.questionId)
        .firstOrNull;
    final questionText = (originalQuestion?.questionText ?? detail.questionText)
        .trim();

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: detail.isCorrect
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  detail.isCorrect ? Iconsax.tick_circle : Iconsax.close_circle,
                  size: 16.r,
                  color: detail.isCorrect ? AppColors.success : AppColors.error,
                ),
                SizedBox(width: 6.w),
                Text(
                  detail.isCorrect ? 'correct'.tr() : 'incorrect'.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: detail.isCorrect
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Question text
          Text(
            questionText.isNotEmpty ? questionText : 'question'.tr(),
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(context),
              height: 1.4,
            ),
          ),
          SizedBox(height: 24.h),

          // Find the original question to get all options
          ..._buildAnswerOptions(context),

          // Explanation
          if (detail.explanation != null && detail.explanation!.isNotEmpty) ...[
            SizedBox(height: 24.h),
            ReviewExplanationCard(explanation: detail.explanation!),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildAnswerOptions(BuildContext context) {
    // Try to find the original question for full options list
    final originalQuestion = (quizDetail ?? fallbackQuiz)?.questions
        .where((q) => q.id == detail.questionId)
        .firstOrNull;

    if (originalQuestion != null) {
      return originalQuestion.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final hasUserAnswer = detail.userAnswer.trim().isNotEmpty;
        final isUserAnswer = hasUserAnswer && option == detail.userAnswer;
        final isCorrectAnswer = option == detail.correctAnswer;

        return ReviewAnswerOption(
          option: option,
          label: String.fromCharCode(65 + index),
          isUserAnswer: isUserAnswer,
          isCorrectAnswer: isCorrectAnswer,
        );
      }).toList();
    }

    // Fallback: show just user answer and correct answer
    return [
      ReviewAnswerOption(
        option: detail.userAnswer,
        label: 'your_answer'.tr(),
        isUserAnswer: true,
        isCorrectAnswer: detail.isCorrect,
      ),
      if (!detail.isCorrect)
        ReviewAnswerOption(
          option: detail.correctAnswer,
          label: 'correct'.tr(),
          isUserAnswer: false,
          isCorrectAnswer: true,
        ),
    ];
  }
}
