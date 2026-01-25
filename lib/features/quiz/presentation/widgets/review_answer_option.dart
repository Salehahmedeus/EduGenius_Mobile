import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';

class ReviewAnswerOption extends StatelessWidget {
  final String option;
  final String label;
  final bool isUserAnswer;
  final bool isCorrectAnswer;

  const ReviewAnswerOption({
    super.key,
    required this.option,
    required this.label,
    required this.isUserAnswer,
    required this.isCorrectAnswer,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    IconData? trailingIcon;
    Color? iconColor;

    if (isCorrectAnswer) {
      backgroundColor = AppColors.success.withOpacity(0.1);
      borderColor = AppColors.success;
      trailingIcon = Iconsax.tick_circle5;
      iconColor = AppColors.success;
    } else if (isUserAnswer && !isCorrectAnswer) {
      backgroundColor = AppColors.error.withOpacity(0.1);
      borderColor = AppColors.error;
      trailingIcon = Iconsax.close_circle5;
      iconColor = AppColors.error;
    } else {
      backgroundColor = AppColors.getSurface(context);
      borderColor = AppColors.getBorder(context).withOpacity(0.5);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 1.5.w),
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: isCorrectAnswer
                  ? AppColors.success
                  : isUserAnswer
                  ? AppColors.error
                  : AppColors.getSurface(context),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                  color: isCorrectAnswer || isUserAnswer
                      ? AppColors.white
                      : AppColors.getTextPrimary(context),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              option,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.getTextPrimary(context),
              ),
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, color: iconColor, size: 24.r),
        ],
      ),
    );
  }
}
