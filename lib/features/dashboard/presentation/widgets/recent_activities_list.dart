import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/dashboard_model.dart';

class RecentActivitiesList extends StatelessWidget {
  final List<Activity> activities;

  const RecentActivitiesList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: activities.map((activity) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.getSurface(context),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.getBorder(context).withOpacity(0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color:
                      (activity.type == 'quiz'
                              ? AppColors.primary
                              : AppColors.info)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  activity.type == 'quiz'
                      ? Iconsax.task_square
                      : Iconsax.document_upload,
                  color: activity.type == 'quiz'
                      ? AppColors.primary
                      : AppColors.info,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      activity.timeAgo,
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        color: AppColors.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
