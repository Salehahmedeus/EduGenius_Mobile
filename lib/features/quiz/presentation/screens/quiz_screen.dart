import 'package:easy_localization/easy_localization.dart';
import 'package:edugenius_mobile/features/quiz/data/models/quiz_result_model.dart';
import 'package:edugenius_mobile/features/quiz/presentation/screens/quiz_review_screen.dart';
import 'package:edugenius_mobile/features/quiz/presentation/screens/quiz_taking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/models/quiz_model.dart';
import '../../data/services/quiz_service.dart';
import 'quiz_setup_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: CustomAppBar(title: 'quizzes'.tr(), showBackButton: false),
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
          'new_quiz'.tr(),
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildContent(ColorScheme colorScheme) {
    if (_quizHistory.isEmpty) {
      return _buildEmptyState(colorScheme);
    }

    return LiquidPullToRefresh(
      onRefresh: _loadQuizHistory,
      color: AppColors.primary,
      backgroundColor: AppColors.getSurface(context),
      showChildOpacityTransition: false,
      springAnimationDurationInMilliseconds: 500,
      child: ListView.builder(
        padding: EdgeInsets.all(16.r),
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
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.note_2, size: 64.r, color: AppColors.primary),
            ),
            SizedBox(height: 24.h),
            Text(
              'no_quizzes_yet'.tr(),
              style: GoogleFonts.outfit(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'create_first_quiz_msg'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: AppColors.getTextSecondary(context),
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
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
                'create_quiz'.tr(),
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
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
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.getBorder(context).withOpacity(0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => _handleQuizTap(quiz),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        isCompleted ? Iconsax.tick_circle : Iconsax.note_2,
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.primary,
                        size: 24.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.topic,
                            style: GoogleFonts.outfit(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextPrimary(context),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${quiz.questions.length} ${'questions'.tr()}',
                            style: GoogleFonts.outfit(
                              fontSize: 12.sp,
                              color: AppColors.getTextSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCompleted && quiz.score != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getScoreColor(quiz.score!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${quiz.score!.toStringAsFixed(0)}%',
                          style: GoogleFonts.outfit(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: _getScoreColor(quiz.score!),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: difficultyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
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
                          SizedBox(width: 6.w),
                          Text(
                            quiz.difficultyLabel.tr(),
                            style: GoogleFonts.outfit(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: difficultyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.getItemColor(context),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCompleted ? Iconsax.tick_circle : Iconsax.timer_1,
                            size: 12.r,
                            color: isCompleted
                                ? AppColors.success
                                : AppColors.getTextSecondary(context),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            isCompleted ? 'completed'.tr() : 'pending'.tr(),
                            style: GoogleFonts.outfit(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: isCompleted
                                  ? AppColors.success
                                  : AppColors.getTextSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (quiz.createdAt != null)
                      Text(
                        DateFormat(
                          'MMM d, yyyy',
                          context.locale.languageCode,
                        ).format(quiz.createdAt!),
                        style: GoogleFonts.outfit(
                          fontSize: 11.sp,
                          color: AppColors.getTextSecondary(context),
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
          feedback: "Review Mode",
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
        msg: "Error: $e",
        backgroundColor: AppColors.error,
      );
      print("Quiz Tap Error: $e");
    }
  }
}
