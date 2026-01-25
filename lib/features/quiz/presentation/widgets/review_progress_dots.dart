import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/quiz_result_model.dart';

class ReviewProgressDots extends StatelessWidget {
  final List<QuestionResultDetail> details;
  final int currentIndex;
  final Function(int) onDotTap;

  const ReviewProgressDots({
    super.key,
    required this.details,
    required this.currentIndex,
    required this.onDotTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: details.asMap().entries.map((entry) {
            final index = entry.key;
            final detail = entry.value;
            final isCurrent = index == currentIndex;

            return GestureDetector(
              onTap: () => onDotTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: isCurrent ? 28.r : 20.r,
                height: isCurrent ? 28.r : 20.r,
                decoration: BoxDecoration(
                  color:
                      (detail.isCorrect ? AppColors.success : AppColors.error)
                          .withOpacity(isCurrent ? 1 : 0.3),
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(color: AppColors.background, width: 2.w)
                      : null,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color:
                                (detail.isCorrect
                                        ? AppColors.success
                                        : AppColors.error)
                                    .withOpacity(0.4),
                            blurRadius: 8.r,
                            spreadRadius: 1.r,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.outfit(
                      fontSize: isCurrent ? 12.sp : 10.sp,
                      fontWeight: FontWeight.w600,
                      color: isCurrent
                          ? AppColors.white
                          : (detail.isCorrect
                                ? AppColors.success
                                : AppColors.error),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
