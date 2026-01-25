import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/data/models/user_model.dart';

class SettingsProfileHeader extends StatelessWidget {
  final UserModel? user;
  final bool isLoading;

  const SettingsProfileHeader({
    super.key,
    required this.user,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final initials = user?.initials ?? 'U';
    final name = user?.name ?? 'User';
    final email = user?.email ?? '';

    return Column(
      children: [
        SizedBox(height: 16.h),
        CircleAvatar(
          radius: 60.r,
          backgroundColor: AppColors.primary,
          child: Text(
            initials,
            style: GoogleFonts.outfit(
              fontSize: 40.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          name,
          style: TextStyle(
            color: AppColors.getTextPrimary(context),
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          email,
          style: TextStyle(
            color: AppColors.getTextSecondary(context),
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}
