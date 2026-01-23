import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

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
        msg: 'Failed to load materials',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _generateQuiz() async {
    if (_selectedMaterialIds.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please select at least one material',
        backgroundColor: Colors.orange,
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
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG, // Keep it on screen longer
      );
    }
  }

  String _getDifficultyLabel(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      default:
        return 'Easy';
    }
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Quiz',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
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
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.document_upload,
                size: 80,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No Materials Found',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload some study materials first to generate a quiz.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: colorScheme.outline,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Difficulty Selection
            _buildDifficultySection(colorScheme),
            const SizedBox(height: 24),

            // Materials Selection
            _buildMaterialsSection(colorScheme),

            // Bottom padding for FAB
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.chart_2, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Difficulty Level',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedDifficulty,
                isExpanded: true,
                icon: Icon(Iconsax.arrow_down_1, color: colorScheme.primary),
                items: [1, 2, 3].map((difficulty) {
                  return DropdownMenuItem<int>(
                    value: difficulty,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(difficulty),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getDifficultyLabel(difficulty),
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
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
            Icon(Iconsax.document_text, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Select Materials',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_selectedMaterialIds.length} selected',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withOpacity(0.1)
            : colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outline.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withOpacity(0.2)
                        : colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getFileIcon(material.fileType),
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.fileName,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        material.fileType.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: colorScheme.outline,
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
                  activeColor: colorScheme.primary,
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isEnabled ? _generateQuiz : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            disabledBackgroundColor: colorScheme.outline.withOpacity(0.3),
            foregroundColor: colorScheme.onPrimary,
            elevation: isEnabled ? 4 : 0,
            shadowColor: colorScheme.primary.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isGeneratingQuiz
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Generating Quiz...',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.play_circle, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Start Quiz',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
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
