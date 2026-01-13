class ApiEndpoints {
  // For Android Emulator, use 10.0.2.2 instead of localhost or custom domains
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  // static const String baseUrl = 'https://edugenius.test/api';

  static const String login = '/login';
  static const String register = '/register';
  static const String sendOtp = '/otp/send';
  static const String verifyOtp = '/otp/verify';
  static const String logout = '/logout';
  static const String profile = '/me';
  static const String materials = '/materials';
  static const String uploadMaterial = '/materials/upload';
}
