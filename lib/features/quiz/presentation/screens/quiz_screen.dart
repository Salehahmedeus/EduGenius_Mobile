import 'package:edugenius_mobile/features/quiz/data/models/quiz_result_model.dart';
import 'package:edugenius_mobile/features/quiz/presentation/screens/quiz_review_screen.dart';
import 'package:edugenius_mobile/features/quiz/presentation/screens/quiz_taking_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/models/quiz_model.dart';
import '../../data/services/quiz_service.dart';
import 'quiz_setup_screen.dart';
import '../../../../core/constants/app_colors.dart';

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
      setState(() {
        _quizHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
        msg: 'Failed to load quiz history',
        backgroundColor: AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Quizzes',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Iconsax.refresh, color: AppColors.black),
            onPressed: _loadQuizHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(colorScheme),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuizSetupScreen()),
          ).then((_) => _loadQuizHistory());
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Iconsax.add),
        label: Text(
          'New Quiz',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildContent(ColorScheme colorScheme) {
    if (_quizHistory.isEmpty) {
      return _buildEmptyState(colorScheme);
    }

    return RefreshIndicator(
      onRefresh: _loadQuizHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _quizHistory.length,
        itemBuilder: (context, index) {
          return _buildQuizCard(_quizHistory[index], colorScheme);
        },
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.note_2, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'No Quizzes Yet',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first AI-powered quiz\nto test your knowledge!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizSetupScreen(),
                  ),
                ).then((_) => _loadQuizHistory());
              },
              icon: const Icon(Iconsax.add),
              label: Text(
                'Create Quiz',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(QuizModel quiz, ColorScheme colorScheme) {
    final isCompleted = quiz.isCompleted;
    final difficultyColor = _getDifficultyColor(quiz.difficulty);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleQuizTap(quiz),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isCompleted ? Iconsax.tick_circle : Iconsax.note_2,
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.topic,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${quiz.questions.length} questions',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCompleted && quiz.score != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getScoreColor(quiz.score!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${quiz.score!.toStringAsFixed(0)}%',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getScoreColor(quiz.score!),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: difficultyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: difficultyColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            quiz.difficultyLabel,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: difficultyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCompleted ? Iconsax.tick_circle : Iconsax.timer_1,
                            size: 12,
                            color: isCompleted
                                ? AppColors.success
                                : AppColors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isCompleted ? 'Completed' : 'Pending',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isCompleted
                                  ? AppColors.success
                                  : AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (quiz.createdAt != null)
                      Text(
                        DateFormat('MMM d, yyyy').format(quiz.createdAt!),
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: AppColors.grey,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return AppColors.success;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.error;
      default:
        return AppColors.success;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  Future<void> _handleQuizTap(QuizModel quiz) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // ============================================
      // PATH A: PENDING QUIZ -> GO TO TAKING SCREEN
      // ============================================
      if (!quiz.isCompleted) {
        // We fetch details to ensure we have all questions loaded
        final fullQuiz = await _quizService.getQuizDetail(quiz.id);

        if (mounted) {
          Navigator.pop(context); // Close loading

          // Go to Taking Screen
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizTakingScreen(quiz: fullQuiz),
            ),
          );

          // Refresh list when user comes back (in case they finished it)
          _loadQuizHistory();
        }
        return;
      }

      // ============================================
      // PATH B: COMPLETED QUIZ -> GO TO REVIEW SCREEN
      // ============================================

      // 1. Fetch full quiz details (includes questions + options)
      final fullQuiz = await _quizService.getQuizDetail(quiz.id);

      if (mounted) Navigator.pop(context); // Close loading

      // 2. Build review details from questions (options shown from fullQuiz)
      // 2. Build review details
      QuizResultModel result;

      if (fullQuiz.result != null) {
        result = fullQuiz.result!;
      } else {
        // Fallback: Build review details from questions if no result attached
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

        // Create Result Model
        result = QuizResultModel(
          quizId: quiz.id,
          score: score,
          totalQuestions: totalQuestions,
          correctAnswers: correctAnswers,
          feedback: "Review Mode",
          details: details,
        );
      }

      if (!mounted) return;

      // 3. Navigate
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
        msg: "Error: $e",
        backgroundColor: AppColors.error,
      );
      print("Quiz Tap Error: $e");
    }
  }
}
