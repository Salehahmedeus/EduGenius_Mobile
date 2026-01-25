import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/quiz_model.dart';
import '../../data/models/quiz_result_model.dart';
import '../widgets/quiz_feedback_card.dart';
import '../widgets/result_action_buttons.dart';
import '../widgets/result_header.dart';
import '../widgets/score_circle.dart';
import '../widgets/score_details_card.dart';
import 'quiz_review_screen.dart';

/// Screen displaying quiz results with score and feedback
class QuizResultScreen extends StatelessWidget {
  final QuizResultModel result;
  final QuizModel quiz;

  const QuizResultScreen({super.key, required this.result, required this.quiz});

  @override
  Widget build(BuildContext context) {
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
              ResultHeader(result: result),
              SizedBox(height: 40.h),

              // Score Circle
              ScoreCircle(result: result),
              SizedBox(height: 32.h),

              // Score details
              ScoreDetailsCard(result: result),
              SizedBox(height: 32.h),

              // AI Feedback
              QuizFeedbackCard(feedback: result.feedback),
              SizedBox(height: 32.h),

              // Action buttons
              ResultActionButtons(
                onReview: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          QuizReviewScreen(result: result, quiz: quiz),
                    ),
                  );
                },
                onHome: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
