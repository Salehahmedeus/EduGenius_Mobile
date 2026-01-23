import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

import '../../data/models/quiz_model.dart';
import '../../data/models/quiz_result_model.dart';
import '../../data/services/quiz_service.dart';

/// Screen for reviewing quiz answers after completion
class QuizReviewScreen extends StatefulWidget {
  final QuizResultModel result;
  final QuizModel quiz;

  const QuizReviewScreen({super.key, required this.result, required this.quiz});

  @override
  State<QuizReviewScreen> createState() => _QuizReviewScreenState();
}

class _QuizReviewScreenState extends State<QuizReviewScreen> {
  int _currentQuestionIndex = 0;
  final PageController _pageController = PageController();
  final QuizService _quizService = QuizService();

  QuizModel? _quizDetail;
  bool _isLoadingDetail = false;

  List<QuestionResultDetail> get details => widget.result.details;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadQuizDetailIfNeeded();
  }

  Future<void> _loadQuizDetailIfNeeded() async {
    if (widget.quiz.questions.isNotEmpty) {
      _quizDetail = widget.quiz;
      return;
    }

    final quizId = widget.quiz.id != 0 ? widget.quiz.id : widget.result.quizId;
    if (quizId == 0) return;

    try {
      setState(() => _isLoadingDetail = true);
      final detail = await _quizService.getQuizDetail(quizId);
      if (!mounted) return;
      setState(() {
        _quizDetail = detail;
        _isLoadingDetail = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingDetail = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Review Answers',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            Text(
              'Question ${_currentQuestionIndex + 1} of ${details.length}',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: AppColors.getTextSecondary(context),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress dots
          _buildProgressDots(colorScheme),
          const SizedBox(height: 8),

          // Questions
          Expanded(
            child: _isLoadingDetail
                ? const Center(child: CircularProgressIndicator())
                : PageView.builder(
                    controller: _pageController,
                    itemCount: details.length,
                    onPageChanged: (index) {
                      setState(() => _currentQuestionIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return _buildQuestionReview(details[index], colorScheme);
                    },
                  ),
          ),

          // Navigation
          _buildNavigation(colorScheme),
        ],
      ),
    );
  }

  Widget _buildProgressDots(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: details.asMap().entries.map((entry) {
            final index = entry.key;
            final detail = entry.value;
            final isCurrent = index == _currentQuestionIndex;

            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isCurrent ? 28 : 20,
                height: isCurrent ? 28 : 20,
                decoration: BoxDecoration(
                  color:
                      (detail.isCorrect ? AppColors.success : AppColors.error)
                          .withOpacity(isCurrent ? 1 : 0.3),
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(color: AppColors.background, width: 2)
                      : null,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color:
                                (detail.isCorrect
                                        ? AppColors.success
                                        : AppColors.error)
                                    .withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.outfit(
                      fontSize: isCurrent ? 12 : 10,
                      fontWeight: FontWeight.w600,
                      color: isCurrent
                          ? AppColors.white
                          : (detail.isCorrect
                                ? AppColors.success
                                : AppColors.error),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildQuestionReview(
    QuestionResultDetail detail,
    ColorScheme colorScheme,
  ) {
    final originalQuestion = (_quizDetail ?? widget.quiz).questions
        .where((q) => q.id == detail.questionId)
        .firstOrNull;
    final questionText = (originalQuestion?.questionText ?? detail.questionText)
        .trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: detail.isCorrect
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  detail.isCorrect ? Iconsax.tick_circle : Iconsax.close_circle,
                  size: 16,
                  color: detail.isCorrect ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 6),
                Text(
                  detail.isCorrect ? 'Correct' : 'Incorrect',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: detail.isCorrect
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Question text
          Text(
            questionText.isNotEmpty ? questionText : 'Question',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Find the original question to get all options
          ..._buildAnswerOptions(detail, colorScheme),

          // Explanation
          if (detail.explanation != null && detail.explanation!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildExplanationCard(detail.explanation!, colorScheme),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildAnswerOptions(
    QuestionResultDetail detail,
    ColorScheme colorScheme,
  ) {
    // Try to find the original question for full options list
    final originalQuestion = (_quizDetail ?? widget.quiz).questions
        .where((q) => q.id == detail.questionId)
        .firstOrNull;

    if (originalQuestion != null) {
      return originalQuestion.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final hasUserAnswer = detail.userAnswer.trim().isNotEmpty;
        final isUserAnswer = hasUserAnswer && option == detail.userAnswer;
        final isCorrectAnswer = option == detail.correctAnswer;

        return _buildOptionTile(
          option: option,
          label: String.fromCharCode(65 + index),
          isUserAnswer: isUserAnswer,
          isCorrectAnswer: isCorrectAnswer,
          colorScheme: colorScheme,
        );
      }).toList();
    }

    // Fallback: show just user answer and correct answer
    return [
      _buildOptionTile(
        option: detail.userAnswer,
        label: 'Your Answer',
        isUserAnswer: true,
        isCorrectAnswer: detail.isCorrect,
        colorScheme: colorScheme,
      ),
      if (!detail.isCorrect)
        _buildOptionTile(
          option: detail.correctAnswer,
          label: 'Correct',
          isUserAnswer: false,
          isCorrectAnswer: true,
          colorScheme: colorScheme,
        ),
    ];
  }

  Widget _buildOptionTile({
    required String option,
    required String label,
    required bool isUserAnswer,
    required bool isCorrectAnswer,
    required ColorScheme colorScheme,
  }) {
    Color backgroundColor;
    Color borderColor;
    IconData? trailingIcon;
    Color? iconColor;

    if (isCorrectAnswer) {
      backgroundColor = AppColors.success.withOpacity(0.1);
      borderColor = AppColors.success;
      trailingIcon = Iconsax.tick_circle5;
      iconColor = AppColors.success;
    } else if (isUserAnswer && !isCorrectAnswer) {
      backgroundColor = AppColors.error.withOpacity(0.1);
      borderColor = AppColors.error;
      trailingIcon = Iconsax.close_circle5;
      iconColor = AppColors.error;
    } else {
      backgroundColor = AppColors.getSurface(context);
      borderColor = AppColors.getBorder(context).withOpacity(0.5);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCorrectAnswer
                  ? AppColors.success
                  : isUserAnswer
                  ? AppColors.error
                  : AppColors.getSurface(context),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: isCorrectAnswer || isUserAnswer
                      ? AppColors.white
                      : AppColors.getTextPrimary(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              option,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, color: iconColor, size: 24),
        ],
      ),
    );
  }

  Widget _buildExplanationCard(String explanation, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.lamp_on, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Text(
                'Explanation',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.getTextPrimary(context).withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.getBackground(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentQuestionIndex > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.getBorder(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.arrow_left_2, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Previous',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_currentQuestionIndex > 0 &&
                _currentQuestionIndex < details.length - 1)
              const SizedBox(width: 12),
            if (_currentQuestionIndex < details.length - 1)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Icon(Iconsax.arrow_right_3, size: 20),
                    ],
                  ),
                ),
              ),
            if (_currentQuestionIndex == details.length - 1)
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.tick_circle, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Done',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
