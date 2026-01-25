import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

import '../../data/models/quiz_model.dart';
import '../../data/models/quiz_result_model.dart';
import '../../data/services/quiz_service.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/review_navigation_bar.dart';
import '../widgets/review_progress_dots.dart';
import '../widgets/review_question_view.dart';

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
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: CustomAppBar(
        titleWidget: Column(
          children: [
            Text(
              'review_answers'.tr(),
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            Text(
              'question_progress'.tr(
                args: [
                  (_currentQuestionIndex + 1).toString(),
                  details.length.toString(),
                ],
              ),
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                color: AppColors.getTextSecondary(context),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Progress dots
          ReviewProgressDots(
            details: details,
            currentIndex: _currentQuestionIndex,
            onDotTap: (index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          SizedBox(height: 8.h),

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
                      return ReviewQuestionView(
                        detail: details[index],
                        quizDetail: _quizDetail,
                        fallbackQuiz: widget.quiz,
                      );
                    },
                  ),
          ),

          // Navigation
          ReviewNavigationBar(
            currentIndex: _currentQuestionIndex,
            totalQuestions: details.length,
            pageController: _pageController,
            onDone: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
