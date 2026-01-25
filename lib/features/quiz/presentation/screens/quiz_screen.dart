import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/quiz_model.dart';
import '../../data/models/quiz_result_model.dart';
import '../../data/services/quiz_service.dart';
import '../widgets/quiz_card.dart';
import '../widgets/quiz_empty_state.dart';
import 'quiz_review_screen.dart';
import 'quiz_setup_screen.dart';
import 'quiz_taking_screen.dart';

/// Main quiz screen showing quiz history and option to create new quiz
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();
  List<QuizModel> _quizHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizHistory();
  }

  Future<void> _loadQuizHistory() async {
    try {
      setState(() => _isLoading = true);
      final history = await _quizService.getHistory();
      if (mounted) {
        setState(() {
          _quizHistory = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Fluttertoast.showToast(
          msg: 'load_quiz_history_error'.tr(),
          backgroundColor: AppColors.error,
        );
      }
    }
  }

  void _navigateToSetup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuizSetupScreen()),
    ).then((_) => _loadQuizHistory());
  }

  Future<void> _handleQuizTap(QuizModel quiz) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (!quiz.isCompleted) {
        final fullQuiz = await _quizService.getQuizDetail(quiz.id);

        if (mounted) {
          Navigator.pop(context); // Close loading

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizTakingScreen(quiz: fullQuiz),
            ),
          );

          _loadQuizHistory();
        }
        return;
      }

      final fullQuiz = await _quizService.getQuizDetail(quiz.id);

      if (mounted) Navigator.pop(context); // Close loading

      QuizResultModel result;

      if (fullQuiz.result != null) {
        result = fullQuiz.result!;
      } else {
        final totalQuestions = fullQuiz.questions.length;
        final score = quiz.score ?? 0;
        final correctAnswers = totalQuestions == 0
            ? 0
            : ((score / 100) * totalQuestions).round();

        final List<QuestionResultDetail> details = fullQuiz.questions.map((q) {
          return QuestionResultDetail(
            questionId: q.id,
            questionText: q.questionText,
            userAnswer: '',
            correctAnswer: q.correctAnswer ?? '',
            isCorrect: true,
            explanation: q.explanation,
          );
        }).toList();

        result = QuizResultModel(
          quizId: quiz.id,
          score: score,
          totalQuestions: totalQuestions,
          correctAnswers: correctAnswers,
          feedback: "review_mode".tr(),
          details: details,
        );
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              QuizReviewScreen(result: result, quiz: fullQuiz),
        ),
      );
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'quiz_tap_error'.tr(args: [e.toString()]),
        backgroundColor: AppColors.error,
      );
      print("Quiz Tap Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: CustomAppBar(title: 'quizzes'.tr(), showBackButton: false),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quizHistory.isEmpty
          ? QuizEmptyState(onCreateOne: _navigateToSetup)
          : LiquidPullToRefresh(
              onRefresh: _loadQuizHistory,
              color: AppColors.primary,
              backgroundColor: AppColors.getSurface(context),
              showChildOpacityTransition: false,
              springAnimationDurationInMilliseconds: 500,
              child: ListView.builder(
                padding: EdgeInsets.all(16.r),
                itemCount: _quizHistory.length,
                itemBuilder: (context, index) {
                  return QuizCard(
                    quiz: _quizHistory[index],
                    onTap: _handleQuizTap,
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToSetup,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Iconsax.add),
        label: Text(
          'new_quiz'.tr(),
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
