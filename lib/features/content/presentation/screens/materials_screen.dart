import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:edugenius_mobile/core/utils/error_handler.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../data/models/material_model.dart';
import '../../data/services/content_service.dart';

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
        label = 'Today';
      } else if (date == yesterday) {
        label = 'Yesterday';
      } else {
        label = DateFormat('MMMM dd, yyyy').format(date);
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
        child: CircularProgressIndicator(color: Color(0xFF2196F3)),
      ),
    );

    try {
      await _contentService.uploadMaterial(file);
      if (mounted) Navigator.pop(context);
      if (mounted) CustomSnackbar.showSuccess(context, "Upload successful!");
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
      if (mounted) CustomSnackbar.showInfo(context, "Deleted successfully");
      _fetchMaterials();
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, "Delete failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF9FAFB);
    const Color borderColor = Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2196F3),
                      ),
                    )
                  : _groupedMaterials.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _fetchMaterials,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              _buildDateDivider(label),
                              ...materials
                                  .map(
                                    (m) => _buildMaterialCard(m, borderColor),
                                  )
                                  .toList(),
                              const SizedBox(height: 10),
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
        label: const Text('Upload', style: TextStyle(color: Colors.white)),
        icon: const Icon(Iconsax.document_upload, color: Colors.white),
        backgroundColor: const Color(0xFF2196F3),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Study Materials',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_totalCount Files',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2196F3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: _performSearch,
          decoration: const InputDecoration(
            hintText: 'Search your materials...',
            hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            prefixIcon: Icon(
              Iconsax.search_normal,
              size: 20,
              color: Color(0xFF9CA3AF),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildDateDivider(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.withOpacity(0.2))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.withOpacity(0.2))),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(MaterialModel material, Color borderColor) {
    final isPdf = material.fileType.toLowerCase().contains('pdf');
    final iconColor = isPdf ? const Color(0xFFF75555) : const Color(0xFF246BFD);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () {
          // Open material or show details
        },
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isPdf ? Iconsax.document_text : Iconsax.document,
            color: iconColor,
            size: 24,
          ),
        ),
        title: Text(
          material.fileName,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${material.fileType.toUpperCase()} • ${DateFormat('HH:mm').format(material.createdAt)}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Iconsax.more, color: Color(0xFF6B7280), size: 18),
          onSelected: (value) {
            if (value == 'delete') {
              _deleteMaterial(material.id);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.folder_open, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No results for "$_searchQuery"'
                : 'No materials found',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload a document to get started!',
            style: TextStyle(color: Colors.grey),
          ),
          if (_searchQuery.isNotEmpty)
            TextButton(
              onPressed: () {
                _searchController.clear();
                _performSearch("");
              },
              child: const Text('Clear Search'),
            ),
        ],
      ),
    );
  }
}
