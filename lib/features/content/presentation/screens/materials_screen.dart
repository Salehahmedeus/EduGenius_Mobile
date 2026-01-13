import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../data/models/material_model.dart';
import '../../data/services/content_service.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  final ContentService _contentService = ContentService();
  List<MaterialModel> _materials = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMaterials();
  }

  Future<void> _fetchMaterials() async {
    setState(() => _isLoading = true);
    try {
      final materials = await _contentService.getMaterials();
      setState(() {
        _materials = materials;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
        msg: "Error fetching materials: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
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
      Fluttertoast.showToast(
        msg: "Error picking file: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
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
      if (mounted) Navigator.pop(context); // Close loading dialog
      Fluttertoast.showToast(
        msg: "Upload successful!",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      _fetchMaterials();
    } catch (e) {
      if (mounted) Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Upload failed: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _deleteMaterial(int id) async {
    // Optional: Add confirmation dialog
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Material'),
            content: const Text('Are you sure you want to delete this file?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      await _contentService.deleteMaterial(id);
      Fluttertoast.showToast(
        msg: "Deleted successfully",
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
      _fetchMaterials();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Delete failed: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materials'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMaterials,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _materials.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No materials found.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchMaterials,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: _materials.length,
                itemBuilder: (context, index) {
                  final material = _materials[index];
                  final isPdf = material.fileType.toLowerCase().contains('pdf');

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isPdf ? Colors.red : Colors.blue).withOpacity(
                            0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isPdf
                              ? Icons.picture_as_pdf
                              : Icons.insert_drive_file,
                          color: isPdf ? Colors.red : Colors.blue,
                          size: 32,
                        ),
                      ),
                      title: Text(
                        material.fileName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Uploaded: ${DateFormat('MMM dd, yyyy').format(material.createdAt)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.grey,
                        ),
                        onPressed: () => _deleteMaterial(material.id),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndUploadFile,
        label: const Text('Upload'),
        icon: const Icon(Icons.upload_file),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
