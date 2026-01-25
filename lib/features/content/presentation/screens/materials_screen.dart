import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:edugenius_mobile/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:edugenius_mobile/core/utils/error_handler.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../data/models/material_model.dart';
import '../../data/services/content_service.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/date_divider.dart';
import '../widgets/empty_materials_view.dart';
import '../widgets/material_card.dart';
import '../widgets/material_search_bar.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  final ContentService _contentService = ContentService();
  final TextEditingController _searchController = TextEditingController();
  Map<String, List<MaterialModel>> _groupedMaterials = {};
  int _totalCount = 0;
  bool _isLoading = false;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchMaterials();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMaterials() async {
    setState(() => _isLoading = true);
    try {
      final materials = await _contentService.getMaterials();
      if (mounted) {
        setState(() {
          _totalCount = materials.length;
          _groupedMaterials = _groupMaterials(materials);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomSnackbar.showError(context, ErrorHandler.parse(e));
      }
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      final results = query.isEmpty
          ? await _contentService.getMaterials()
          : await _contentService.searchMaterials(query);

      if (mounted) {
        setState(() {
          _groupedMaterials = _groupMaterials(results);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomSnackbar.showError(context, "Search failed: $e");
      }
    }
  }

  Map<String, List<MaterialModel>> _groupMaterials(
    List<MaterialModel> materials,
  ) {
    Map<String, List<MaterialModel>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Sort by date newest first
    materials.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    for (var material in materials) {
      final date = DateTime(
        material.createdAt.year,
        material.createdAt.month,
        material.createdAt.day,
      );
      String label;
      if (date == today) {
        label = 'today'.tr();
      } else if (date == yesterday) {
        label = 'yesterday'.tr();
      } else {
        label = DateFormat(
          'MMMM dd, yyyy',
          context.locale.languageCode,
        ).format(date);
      }

      if (!grouped.containsKey(label)) {
        grouped[label] = [];
      }
      grouped[label]!.add(material);
    }
    return grouped;
  }

  Future<void> _pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        await _uploadFile(file);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, "Error picking file: $e");
      }
    }
  }

  Future<void> _uploadFile(File file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      await _contentService.uploadMaterial(file);
      if (mounted) Navigator.pop(context);
      if (mounted) CustomSnackbar.showSuccess(context, "upload_success".tr());
      _fetchMaterials();
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        CustomSnackbar.showError(context, ErrorHandler.parse(e));
      }
    }
  }

  Future<void> _deleteMaterial(int id) async {
    try {
      await _contentService.deleteMaterial(id);
      if (mounted) CustomSnackbar.showInfo(context, "delete_success".tr());
      _fetchMaterials();
    } catch (e) {
      if (mounted)
        CustomSnackbar.showError(context, "${'delete_failed'.tr()}: $e");
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _performSearch("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: CustomAppBar(
        title: 'materials_header'.tr(),
        showBackButton: false,
        actions: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.getBorder(context)),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  '$_totalCount ${'files'.tr()}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextSecondary(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            MaterialSearchBar(
              controller: _searchController,
              onSubmitted: _performSearch,
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _groupedMaterials.isEmpty
                  ? EmptyMaterialsView(
                      searchQuery: _searchQuery,
                      onClearSearch: _clearSearch,
                    )
                  : LiquidPullToRefresh(
                      onRefresh: _fetchMaterials,
                      color: AppColors.primary,
                      backgroundColor: AppColors.getSurface(context),
                      showChildOpacityTransition: false,
                      springAnimationDurationInMilliseconds: 500,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: _groupedMaterials.length,
                        itemBuilder: (context, index) {
                          String label = _groupedMaterials.keys.elementAt(
                            index,
                          );
                          List<MaterialModel> materials =
                              _groupedMaterials[label]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DateDivider(label: label),
                              ...materials.map(
                                (m) => MaterialCard(
                                  material: m,
                                  onDelete: _deleteMaterial,
                                  onTap: () {
                                    // Open material or show details
                                  },
                                ),
                              ),
                              SizedBox(height: 10.h),
                            ],
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndUploadFile,
        label: Text(
          'upload_material'.tr(),
          style: const TextStyle(color: Colors.white),
        ),
        icon: const Icon(Iconsax.document_upload, color: Colors.white),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
