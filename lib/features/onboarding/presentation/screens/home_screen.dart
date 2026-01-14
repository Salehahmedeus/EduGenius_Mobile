import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_nav.dart';
import 'package:edugenius_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:edugenius_mobile/features/ai_tutor/presentation/screens/chat_screen.dart';
import 'package:edugenius_mobile/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:edugenius_mobile/features/content/presentation/screens/materials_screen.dart';
import 'package:edugenius_mobile/features/settings/presentation/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // Default to Dashboard (index 2)

  // Real screens
  final List<Widget> _screens = [
    const ChatScreen(),
    const MaterialsScreen(),
    const DashboardScreen(),
    const QuizScreen(),
    const SettingsScreen(),
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
