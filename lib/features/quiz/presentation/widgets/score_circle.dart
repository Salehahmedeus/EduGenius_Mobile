import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/quiz_result_model.dart';

class ScoreCircle extends StatelessWidget {
  final QuizResultModel result;

  const ScoreCircle({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final scorePercent = result.score / 100;
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
}
