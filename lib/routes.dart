import 'package:flutter/material.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/ai_tutor/presentation/screens/chat_screen.dart';
import 'features/quiz/presentation/screens/quiz_screen.dart';
import 'features/content/presentation/screens/upload_screen.dart';

class Routes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String aiTutor = '/ai-tutor';
  static const String quiz = '/quiz';
  static const String upload = '/upload';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      welcome: (context) => const WelcomeScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      dashboard: (context) => const DashboardScreen(),
      aiTutor: (context) => const ChatScreen(),
      quiz: (context) => const QuizScreen(),
      upload: (context) => const UploadScreen(),
    };
  }
}
