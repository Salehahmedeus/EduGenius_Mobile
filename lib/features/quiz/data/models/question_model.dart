/// Model representing a single quiz question
class QuestionModel {
  final int id;
  final String questionText;
  final List<String> options;
  final String? correctAnswer;
  final String? explanation;

  QuestionModel({
    required this.id,
    required this.questionText,
    required this.options,
    this.correctAnswer,
    this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? 0,
      questionText: json['question_text'] ?? json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correct_answer'],
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': questionText,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
    };
  }
}
