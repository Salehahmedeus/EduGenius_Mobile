import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../content/data/models/material_model.dart';
import '../../../content/data/services/content_service.dart';
import '../../data/services/quiz_service.dart';
import '../widgets/setup_difficulty_selector.dart';
import '../widgets/setup_material_list.dart';
import '../widgets/setup_start_button.dart';
import 'quiz_taking_screen.dart';

/// Screen for configuring and starting a new quiz
class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  final ContentService _contentService = ContentService();
  final QuizService _quizService = QuizService();

  List<MaterialModel> _materials = [];
  final Set<int> _selectedMaterialIds = {};
  int _selectedDifficulty = 1; // 1=Easy, 2=Medium, 3=Hard
  bool _isLoadingMaterials = true;
  bool _isGeneratingQuiz = false;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    try {
      setState(() => _isLoadingMaterials = true);
      final materials = await _contentService.getMaterials();
      setState(() {
        _materials = materials;
        _isLoadingMaterials = false;
      });
    } catch (e) {
      setState(() => _isLoadingMaterials = false);
      Fluttertoast.showToast(
        msg: 'failed_to_load_data'.tr(),
        backgroundColor: AppColors.error,
      );
    }
  }

  Future<void> _generateQuiz() async {
    if (_selectedMaterialIds.isEmpty) {
      Fluttertoast.showToast(
        msg: 'select_least_one'.tr(),
        backgroundColor: AppColors.warning,
      );
      return;
    }

    try {
      setState(() => _isGeneratingQuiz = true);

      final quiz = await _quizService.generateQuiz(
        materialIds: _selectedMaterialIds.toList(),
        difficulty: _selectedDifficulty,
      );

      setState(() => _isGeneratingQuiz = false);

      if (!mounted) return;

      // Navigate to quiz taking screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QuizTakingScreen(quiz: quiz)),
      );
    } catch (e) {
      setState(() => _isGeneratingQuiz = false);

      // 👇 PRINT TO CONSOLE (Check your "Run" tab in VS Code)
      print("FULL ERROR DETAILS: $e");

      // 👇 SHOW RAW ERROR IN TOAST
      // This will tell us if it's a "Timeout", "FormatException", or something else
      Fluttertoast.showToast(
        msg: 'quiz_gen_error'.tr(args: [e.toString()]),
        backgroundColor: AppColors.error,
        toastLength: Toast.LENGTH_LONG, // Keep it on screen longer
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: CustomAppBar(title: 'create_quiz'.tr()),
      body: SafeArea(
        child: _isLoadingMaterials
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
      floatingActionButton: SetupStartButton(
        isEnabled: _selectedMaterialIds.isNotEmpty && !_isGeneratingQuiz,
        isGenerating: _isGeneratingQuiz,
        onPressed: _generateQuiz,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildContent() {
    if (_materials.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.document_upload,
                size: 80.r,
                color: AppColors.getTextSecondary(context),
              ),
              SizedBox(height: 16.h),
              Text(
                'no_materials_found'.tr(),
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'upload_first_material'.tr(),
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  color: AppColors.getTextSecondary(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMaterials,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Difficulty Selection
            SetupDifficultySelector(
              selectedDifficulty: _selectedDifficulty,
              onDifficultyChanged: (val) {
                setState(() => _selectedDifficulty = val);
              },
            ),
            SizedBox(height: 24.h),

            // Materials Selection
            SetupMaterialList(
              materials: _materials,
              selectedMaterialIds: _selectedMaterialIds,
              onMaterialToggle: (id) {
                setState(() {
                  if (_selectedMaterialIds.contains(id)) {
                    _selectedMaterialIds.remove(id);
                  } else {
                    _selectedMaterialIds.add(id);
                  }
                });
              },
            ),

            // Bottom padding for FAB
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }
}
