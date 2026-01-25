import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/quiz_result_model.dart';

class ResultHeader extends StatelessWidget {
  final QuizResultModel result;

  const ResultHeader({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
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
}
