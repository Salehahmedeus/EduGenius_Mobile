class QuizModel {
  final String id;
  final String title;
  final List<Question> questions;

  QuizModel({required this.id, required this.title, required this.questions});
}

class Question {
  final String text;
  final List<String> options;
  final int correctOptionIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctOptionIndex,
  });
}
