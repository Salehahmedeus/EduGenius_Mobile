import 'package:flutter/material.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40), // Top spacing
              Column(
                children: [
                  Text(
                    'Study Clever',
                    style: TextStyle(
                      fontSize: 32,
                      color: AppColors.primary, // Red color from image
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Less Time',
                    style: TextStyle(
                      fontSize: 36,
                      color: AppColors.primary, // Red color from image
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Central Icon
              SizedBox(
                width: 200,
                height: 200,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                  height: 200,
                ),
              ),
              const Spacer(),
              // Start Button
              CustomButton(
                text: 'Start',
                onPressed: () {
                  Navigator.pushNamed(context, Routes.login);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
