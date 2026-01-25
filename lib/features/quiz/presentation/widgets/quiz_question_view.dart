import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/question_model.dart';
import 'quiz_taking_option.dart';

class QuizQuestionView extends StatelessWidget {
  final QuestionModel question;
  final int questionIndex;
  final String? selectedAnswer;
  final Function(String) onAnswerSelected;

  const QuizQuestionView({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'question_number'.tr(args: [(questionIndex + 1).toString()]),
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Question text
          Text(
            question.questionText,
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(context),
              height: 1.4,
            ),
          ),
          SizedBox(height: 24.h),

          // Options
          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = selectedAnswer == option;
            final optionLabel = String.fromCharCode(65 + index); // A, B, C, D

            return QuizTakingOption(
              option: option,
              label: optionLabel,
              isSelected: isSelected,
              onTap: () => onAnswerSelected(option),
            );
          }),
        ],
      ),
    );
  }
}
