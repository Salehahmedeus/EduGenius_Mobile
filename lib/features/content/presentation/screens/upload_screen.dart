import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:edugenius_mobile/core/constants/app_colors.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: CustomAppBar(title: 'upload_content'.tr()),
      body: Padding(
        padding: EdgeInsets.all(16.0.r),
        child: Column(
          children: [
            CustomTextField(
              controller: titleController,
              hintText: 'content_title'.tr(),
            ),
            SizedBox(height: 16.h),
            Container(
              height: 150.h,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.getBorder(context)),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.cloud_add, size: 48.r, color: AppColors.grey),
                  SizedBox(height: 8.h),
                  Text(
                    'tap_select_file'.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            CustomButton(
              text: 'upload_material'.tr(),
              onPressed: () {
                // Implement upload
              },
            ),
          ],
        ),
      ),
    );
  }
}
