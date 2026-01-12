import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_nav.dart';
import 'package:edugenius_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:edugenius_mobile/features/ai_tutor/presentation/screens/chat_screen.dart';
import 'package:edugenius_mobile/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:edugenius_mobile/features/content/presentation/screens/upload_screen.dart';
// import settings screen if exists, or create placeholder

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // Default to Dashboard (index 2 in CustomNavBar)

  // Real screens
  final List<Widget> _screens = [
    const ChatScreen(),
    const UploadScreen(), // Content/Upload
    const DashboardScreen(),
    const QuizScreen(),
    const Scaffold(
      body: Center(child: Text("Settings")),
    ), // Placeholder for Settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
