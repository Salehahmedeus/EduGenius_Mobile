import 'package:flutter/material.dart';
import 'package:edugenius_mobile/core/constants/app_colors.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: const Text('Upload Content'),
        backgroundColor: AppColors.getBackground(context),
        foregroundColor: AppColors.getTextPrimary(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              controller: titleController,
              hintText: 'Content Title',
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.getBorder(context)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Iconsax.cloud_add, size: 48, color: AppColors.grey),
                  SizedBox(height: 8),
                  Text('Tap to select file'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Upload Material',
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
