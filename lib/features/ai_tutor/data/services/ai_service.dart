class AIService {
  // Simulate AI response for now
  Future<String> getResponse(String query) async {
    await Future.delayed(const Duration(seconds: 1));
    return "This is a simulated AI response to: $query\n\n(Integration with actual AI backend pending)";
  }
}
