import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';

class QuizFeedbackCard extends StatelessWidget {
  final String? feedback;

  const QuizFeedbackCard({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    if (feedback == null || feedback!.isEmpty) {
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
            feedback!,
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
}
