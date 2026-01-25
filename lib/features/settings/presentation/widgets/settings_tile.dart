import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool showDivider;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.onTap,
    this.trailing,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          leading: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: Colors.white, size: 20.r),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: AppColors.getTextPrimary(context),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing:
              trailing ??
              Icon(
                Iconsax.arrow_right_3,
                color: AppColors.getTextSecondary(context),
                size: 18.r,
              ),
        ),
        if (showDivider)
          Divider(
            height: 1.h,
            thickness: 1.h,
            color: AppColors.getBorder(context),
            indent: 60.w,
            endIndent: 16.w,
          ),
      ],
    );
  }
}
