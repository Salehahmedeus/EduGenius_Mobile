import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

import '../../data/models/quiz_model.dart';
import '../../data/models/question_model.dart';
import '../../data/services/quiz_service.dart';
import 'quiz_result_screen.dart';
import '../../../../core/widgets/custom_app_bar.dart';

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
        backgroundColor: AppColors.getSurface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Iconsax.info_circle, color: AppColors.primary, size: 24.r),
            SizedBox(width: 12.w),
            Text(
              'submit_quiz'.tr(),
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'submit_confirm_msg'.tr(),
              style: GoogleFonts.outfit(
                color: AppColors.getTextPrimary(context),
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.getSurface(context),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.tick_circle,
                    color: AppColors.success,
                    size: 20.r,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${_answers.length}/${questions.length} ${'questions_answered'.tr()}',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      color: AppColors.getTextPrimary(context),
                    ),
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
              'review'.tr(),
              style: GoogleFonts.outfit(
                color: AppColors.getTextSecondary(context),
              ),
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
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'submit_quiz'.tr(),
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
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
      print("Quiz Submit UI Error: $e");

      String errorMessage = 'Failed to submit quiz.';
      if (e is DioException) {
        if (e.response?.data != null && e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'];
        } else if (e.message != null) {
          errorMessage = e.message!;
        }
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        backgroundColor: AppColors.error,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getSurface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Iconsax.warning_2, color: AppColors.warning, size: 24.r),
            SizedBox(width: 12.w),
            Text(
              'exit_quiz'.tr(),
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
          ],
        ),
        content: Text(
          'exit_msg'.tr(),
          style: GoogleFonts.outfit(
            color: AppColors.getTextPrimary(context),
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(),
              style: GoogleFonts.outfit(
                color: AppColors.getTextSecondary(context),
              ),
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
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'exit'.tr(),
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
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
        backgroundColor: AppColors.getBackground(context),
        appBar: CustomAppBar(
          onBackPress: _showExitConfirmation,
          leading: IconButton(
            icon: Icon(
              Iconsax.close_circle,
              color: AppColors.getTextPrimary(context),
              size: 24.r,
            ),
            onPressed: _showExitConfirmation,
          ),
          titleWidget: Column(
            children: [
              Text(
                widget.quiz.topic,
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'question_progress'.tr(
                  args: [
                    (_currentQuestionIndex + 1).toString(),
                    questions.length.toString(),
                  ],
                ),
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  color: AppColors.getTextSecondary(context),
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: widget.quiz.difficultyLabel == 'Easy'
                    ? AppColors.success.withOpacity(0.1)
                    : widget.quiz.difficultyLabel == 'Medium'
                    ? AppColors.warning.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    widget.quiz.difficultyLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: widget.quiz.difficultyLabel == 'Easy'
                          ? AppColors.success
                          : widget.quiz.difficultyLabel == 'Medium'
                          ? AppColors.warning
                          : AppColors.error,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: _isSubmitting ? _buildSubmittingState() : _buildQuizContent(),
      ),
    );
  }

  Widget _buildSubmittingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60.r,
            height: 60.r,
            child: CircularProgressIndicator(
              strokeWidth: 3.w,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'submitting_quiz'.tr(),
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'wait_analyze'.tr(),
            style: GoogleFonts.outfit(
              color: AppColors.getTextSecondary(context),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    if (questions.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.danger, size: 48.r, color: AppColors.warning),
              SizedBox(height: 16.h),
              Text(
                'no_questions_found'.tr(),
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'no_questions_msg'.tr(),
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: AppColors.grey,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('go_back'.tr()),
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
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.h,
              backgroundColor: AppColors.getSurface(context),
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
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'question_number'.tr(
                args: [(_currentQuestionIndex + 1).toString()],
              ),
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
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
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(context),
              height: 1.4,
            ),
          ),
          SizedBox(height: 24.h),

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
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16.r),
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
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.getBackground(context),
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
                        fontSize: 16.sp,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.getTextPrimary(context),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    option,
                    style: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Iconsax.tick_circle5,
                    color: AppColors.primary,
                    size: 24.r,
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
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.getBackground(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, -5.h),
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
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    side: BorderSide(color: AppColors.getBorder(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.arrow_left_2, size: 20.r),
                      SizedBox(width: 8.w),
                      Text(
                        'previous'.tr(),
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_currentQuestionIndex > 0) SizedBox(width: 12.w),

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
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  elevation: canProceed ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastQuestion ? 'submit_quiz'.tr() : 'next'.tr(),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      isLastQuestion
                          ? Iconsax.tick_circle
                          : Iconsax.arrow_right_3,
                      size: 20.r,
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
