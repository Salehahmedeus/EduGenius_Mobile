import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/quiz_result_model.dart';

class ScoreDetailsCard extends StatelessWidget {
  final QuizResultModel result;

  const ScoreDetailsCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
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
}
