import 'package:flutter/material.dart';
import '../../../../routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                      color: Color(0xFFD32F2F), // Red color from image
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Less Time',
                    style: TextStyle(
                      fontSize: 36,
                      color: Color(0xFFD32F2F), // Red color from image
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Central Icon
              Container(
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
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
