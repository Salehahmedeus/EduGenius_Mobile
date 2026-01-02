import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _onboardingKey = 'has_seen_onboarding';

  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }
}
