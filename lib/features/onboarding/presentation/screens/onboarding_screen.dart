import 'package:flutter/material.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      image: 'assets/images/onboarding_1.png',
      title: 'Your AI Study Partner',
      description: 'Get personalized help with your studies anytime, anywhere.',
    ),
    OnboardingContent(
      image: 'assets/images/onboarding_2.png',
      title: 'Smart Knowledge Base',
      description:
          'Access a vast library of knowledge tailored to your curriculum.',
    ),
    OnboardingContent(
      image: 'assets/images/onboarding_3.png',
      title: 'Achieve Academic Success',
      description: 'Boost your grades and learn more effectively with AI.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(_contents[index].image, height: 300),
                        const SizedBox(height: 48),
                        Text(
                          _contents[index].title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD32F2F),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _contents[index].description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _contents.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFFD32F2F)
                              : Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Button
                  ElevatedButton(
                    onPressed: () async {
                      if (_currentPage == _contents.length - 1) {
                        await AppPreferences.setOnboardingSeen();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            Routes.welcome,
                          );
                        }
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingContent {
  final String image;
  final String title;
  final String description;

  OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}
