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
    // Options may arrive as a list or a map; normalize to a list of strings
    final rawOptions = json['options'];
    List<String> optionsList;

    if (rawOptions is List) {
      optionsList = rawOptions.map((e) => e.toString()).toList();
    } else if (rawOptions is Map) {
      optionsList = rawOptions.values.map((e) => e.toString()).toList();
    } else if (rawOptions is String) {
      // Fallback when options are delivered as a comma separated string
      optionsList = rawOptions.split(',').map((e) => e.trim()).toList();
    } else {
      optionsList = [];
    }

    return QuestionModel(
      id: json['id'] is String
          ? int.tryParse(json['id']) ?? 0
          : (json['id'] ?? 0),
      questionText: json['question_text'] ?? json['question'] ?? '',
      options: optionsList,
      correctAnswer: json['correct_answer']?.toString(),
      explanation: json['explanation']?.toString(),
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
