import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quizzes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildQuizItem(context, 'General Knowledge', '10 Questions'),
          _buildQuizItem(context, 'Mathematics Basics', '15 Questions'),
          _buildQuizItem(context, 'Science 101', '12 Questions'),
        ],
      ),
    );
  }

  Widget _buildQuizItem(BuildContext context, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.quiz, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to quiz details
        },
      ),
    );
  }
}
