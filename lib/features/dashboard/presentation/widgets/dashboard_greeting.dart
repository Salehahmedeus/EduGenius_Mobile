import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/dashboard_model.dart';

class DashboardGreeting extends StatelessWidget {
  final DashboardUser user;

  const DashboardGreeting({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30.r,
          backgroundColor: AppColors.primary,
          child: Text(
            user.avatarInitials,
            style: GoogleFonts.outfit(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'welcome_back'.tr(),
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: AppColors.getTextSecondary(context),
              ),
            ),
            Text(
              user.name,
              style: GoogleFonts.outfit(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
