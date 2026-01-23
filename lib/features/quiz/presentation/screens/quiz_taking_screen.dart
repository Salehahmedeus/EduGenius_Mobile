import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

import '../../data/models/quiz_model.dart';
import '../../data/models/question_model.dart';
import '../../data/services/quiz_service.dart';
import 'quiz_result_screen.dart';

/// Screen for taking a quiz - displays questions one at a time
class QuizTakingScreen extends StatefulWidget {
  final QuizModel quiz;

  const QuizTakingScreen({super.key, required this.quiz});

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  final QuizService _quizService = QuizService();
  final PageController _pageController = PageController();

  final Map<int, String> _answers = {};
  int _currentQuestionIndex = 0;
  bool _isSubmitting = false;

  List<QuestionModel> get questions => widget.quiz.questions;
  bool get isLastQuestion =>
      questions.isNotEmpty && _currentQuestionIndex == questions.length - 1;
  bool get canProceed =>
      questions.isNotEmpty &&
      _answers.containsKey(questions[_currentQuestionIndex].id);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectAnswer(int questionId, String answer) {
    setState(() {
      _answers[questionId] = answer;
    });
  }

  void _nextQuestion() {
    if (!canProceed) {
      Fluttertoast.showToast(
        msg: 'Please select an answer',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    if (isLastQuestion) {
      _showSubmitConfirmation();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showSubmitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Iconsax.info_circle, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              'Submit Quiz',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to submit your quiz?',
              style: GoogleFonts.outfit(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.tick_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${_answers.length}/${questions.length} questions answered',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Review',
              style: GoogleFonts.outfit(color: AppColors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitQuiz();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Submit',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitQuiz() async {
    try {
      setState(() => _isSubmitting = true);

      final result = await _quizService.submitQuiz(
        quizId: widget.quiz.id,
        answers: _answers,
      );

      setState(() => _isSubmitting = false);

      if (!mounted) return;

      // Navigate to results screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              QuizResultScreen(result: result, quiz: widget.quiz),
        ),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      Fluttertoast.showToast(
        msg: 'Failed to submit quiz. Please try again.',
        backgroundColor: AppColors.error,
      );
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Iconsax.warning_2, color: AppColors.warning),
            const SizedBox(width: 12),
            Text(
              'Exit Quiz?',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'Your progress will be lost. Are you sure you want to exit?',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: AppColors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Exit',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (!didPop) {
          _showExitConfirmation();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: _isSubmitting ? _buildSubmittingState() : _buildQuizContent(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Iconsax.close_circle, color: AppColors.black),
        onPressed: _showExitConfirmation,
      ),
      title: Column(
        children: [
          Text(
            widget.quiz.topic,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Question ${_currentQuestionIndex + 1} of ${questions.length}',
            style: GoogleFonts.outfit(fontSize: 12, color: AppColors.grey),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.quiz.difficultyLabel == 'Easy'
                ? AppColors.success.withOpacity(0.1)
                : widget.quiz.difficultyLabel == 'Medium'
                ? AppColors.warning.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.quiz.difficultyLabel,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.quiz.difficultyLabel == 'Easy'
                  ? AppColors.success
                  : widget.quiz.difficultyLabel == 'Medium'
                  ? AppColors.warning
                  : AppColors.error,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmittingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Submitting Quiz...',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we analyze your answers',
            style: GoogleFonts.outfit(color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    if (questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.danger, size: 48, color: AppColors.warning),
              const SizedBox(height: 16),
              Text(
                'No Questions Found',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We couldn\'t load any questions for this quiz. Please try again or contact support.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: AppColors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Progress indicator
        _buildProgressIndicator(),

        // Questions PageView
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: questions.length,
            onPageChanged: (index) {
              setState(() => _currentQuestionIndex = index);
            },
            itemBuilder: (context, index) {
              return _buildQuestionCard(questions[index]);
            },
          ),
        ),

        // Navigation buttons
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    if (questions.isEmpty) return const SizedBox.shrink();
    final progress = (_currentQuestionIndex + 1) / questions.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.lightGrey,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionModel question) {
    final selectedAnswer = _answers[question.id];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Question ${_currentQuestionIndex + 1}',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Question text
          Text(
            question.questionText,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Options
          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = selectedAnswer == option;
            final optionLabel = String.fromCharCode(65 + index); // A, B, C, D

            return _buildOptionTile(
              option: option,
              label: optionLabel,
              isSelected: isSelected,
              onTap: () => _selectAnswer(question.id, option),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required String option,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.lightGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.grey.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.lightGrey,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.white : AppColors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: AppColors.black,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Iconsax.tick_circle5,
                    color: AppColors.primary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
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
            // Previous button
            if (_currentQuestionIndex > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousQuestion,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.grey.withOpacity(0.3)),
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
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            if (_currentQuestionIndex > 0) const SizedBox(width: 12),

            // Next/Submit button
            Expanded(
              flex: _currentQuestionIndex > 0 ? 1 : 2,
              child: ElevatedButton(
                onPressed: canProceed ? _nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLastQuestion
                      ? AppColors.success
                      : AppColors.primary,
                  disabledBackgroundColor: AppColors.grey.withOpacity(0.3),
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: canProceed ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastQuestion ? 'Submit' : 'Next',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isLastQuestion
                          ? Iconsax.tick_circle
                          : Iconsax.arrow_right_3,
                      size: 20,
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
