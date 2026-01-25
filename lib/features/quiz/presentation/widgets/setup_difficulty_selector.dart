import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';

class SetupDifficultySelector extends StatelessWidget {
  final int selectedDifficulty;
  final Function(int) onDifficultyChanged;

  const SetupDifficultySelector({
    super.key,
    required this.selectedDifficulty,
    required this.onDifficultyChanged,
  });

  String _getDifficultyLabel(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'easy'.tr();
      case 2:
        return 'medium'.tr();
      case 3:
        return 'hard'.tr();
      default:
        return 'easy'.tr();
    }
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return AppColors.success;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.error;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.getBorder(context).withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.chart_2, color: AppColors.primary, size: 20.r),
              SizedBox(width: 8.w),
              Text(
                'difficulty_level'.tr(),
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.getBackground(context),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.grey.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedDifficulty,
                isExpanded: true,
                icon: Icon(
                  Iconsax.arrow_down_1,
                  color: AppColors.primary,
                  size: 24.r,
                ),
                items: [1, 2, 3].map((difficulty) {
                  return DropdownMenuItem<int>(
                    value: difficulty,
                    child: Row(
                      children: [
                        Container(
                          width: 10.r,
                          height: 10.r,
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(difficulty),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          _getDifficultyLabel(difficulty),
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                            color: AppColors.getTextPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onDifficultyChanged(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
