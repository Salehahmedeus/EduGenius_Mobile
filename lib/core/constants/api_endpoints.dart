class ApiEndpoints {
  // For Android Emulator, use 10.0.2.2 instead of localhost or custom domains
  // static const String baseUrl = 'http://192.168.31.65:8000/api'; for mobile testing
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
  static const String searchMaterials = '/materials/search';

  // AI Tutor
  static const String aiChats = '/ai/chats';
  static const String aiHistory = '/ai/history'; // + /{id}
  static const String aiAsk = '/ai/ask';

  // Quiz
  static const String quizGenerate = '/quiz/generate';
  static const String quizSubmit = '/quiz/submit';
  static const String quizHistory =
      '/quiz/all'; // or /quiz/all based on your backend
  static const String quizDetail = '/quiz'; // for /quiz/{id}
}
