import 'package:easy_localization/easy_localization.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

import '../../../content/data/services/content_service.dart';
import '../../../content/data/models/material_model.dart';
import '../../data/services/quiz_service.dart';
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
        msg: "Error: $e",
        backgroundColor: AppColors.error,
        toastLength: Toast.LENGTH_LONG, // Keep it on screen longer
      );
    }
  }

  String _getDifficultyLabel(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'easy'.tr();
      case 2:
        return 'medium'.tr();
      case 3:
        return 'hard'.tr();
      default:
        return 'easy'.tr();
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: CustomAppBar(title: 'create_quiz'.tr()),
      body: _isLoadingMaterials
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(colorScheme),
      floatingActionButton: _buildStartButton(colorScheme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildContent(ColorScheme colorScheme) {
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
            _buildDifficultySection(colorScheme),
            SizedBox(height: 24.h),

            // Materials Selection
            _buildMaterialsSection(colorScheme),

            // Bottom padding for FAB
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySection(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.getBorder(context).withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.chart_2, color: AppColors.primary, size: 20.r),
              SizedBox(width: 8.w),
              Text(
                'difficulty_level'.tr(),
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.getBackground(context),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.grey.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedDifficulty,
                isExpanded: true,
                icon: Icon(
                  Iconsax.arrow_down_1,
                  color: AppColors.primary,
                  size: 24.r,
                ),
                items: [1, 2, 3].map((difficulty) {
                  return DropdownMenuItem<int>(
                    value: difficulty,
                    child: Row(
                      children: [
                        Container(
                          width: 10.r,
                          height: 10.r,
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(difficulty),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          _getDifficultyLabel(difficulty),
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                            color: AppColors.getTextPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedDifficulty = value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.document_text, color: colorScheme.primary, size: 20.r),
            SizedBox(width: 8.w),
            Text(
              'select_material'.tr(),
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'selected_count'.tr(
                  args: [_selectedMaterialIds.length.toString()],
                ),
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _materials.length,
          itemBuilder: (context, index) {
            final material = _materials[index];
            final isSelected = _selectedMaterialIds.contains(material.id);

            return _buildMaterialItem(material, isSelected, colorScheme);
          },
        ),
      ],
    );
  }

  Widget _buildMaterialItem(
    MaterialModel material,
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.getBorder(context).withOpacity(0.5),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedMaterialIds.remove(material.id);
              } else {
                _selectedMaterialIds.add(material.id);
              }
            });
          },
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    _getFileIcon(material.fileType),
                    color: colorScheme.primary,
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.fileName,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                          color: AppColors.getTextPrimary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        material.fileType.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedMaterialIds.add(material.id);
                      } else {
                        _selectedMaterialIds.remove(material.id);
                      }
                    });
                  },
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Iconsax.document_text;
      case 'doc':
      case 'docx':
        return Iconsax.document;
      case 'ppt':
      case 'pptx':
        return Iconsax.presention_chart;
      case 'txt':
        return Iconsax.text;
      default:
        return Iconsax.document_1;
    }
  }

  Widget _buildStartButton(ColorScheme colorScheme) {
    final isEnabled = _selectedMaterialIds.isNotEmpty && !_isGeneratingQuiz;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: isEnabled ? _generateQuiz : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.grey.withOpacity(0.3),
            foregroundColor: AppColors.white,
            elevation: isEnabled ? 4 : 0,
            shadowColor: AppColors.primary.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          child: _isGeneratingQuiz
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'generating_quiz'.tr(),
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.play_circle, size: 22.r),
                    SizedBox(width: 8.w),
                    Text(
                      'start_quiz'.tr(),
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
