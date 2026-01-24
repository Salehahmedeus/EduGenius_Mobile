import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../routes.dart';
import '../../../../core/widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 24.0.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 40.h), // Top spacing
              Column(
                children: [
                  Text(
                    'study_clever'.tr(),
                    style: TextStyle(
                      fontSize: 32.sp,
                      color: AppColors.primary, // Red color from image
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'less_time'.tr(),
                    style: TextStyle(
                      fontSize: 36.sp,
                      color: AppColors.primary, // Red color from image
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Central Icon
              SizedBox(
                width: 200.r,
                height: 200.r,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 200.r,
                  height: 200.r,
                ),
              ),
              const Spacer(),
              // Start Button
              CustomButton(
                text: 'start'.tr(),
                onPressed: () {
                  Navigator.pushNamed(context, Routes.login);
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
