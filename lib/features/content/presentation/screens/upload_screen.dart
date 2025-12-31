import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Content')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              controller: titleController,
              label: 'Content Title',
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.cloud_upload, size: 48, color: Colors.grey),
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
