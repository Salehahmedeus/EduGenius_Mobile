import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/material_model.dart';

class ContentService {
  final ApiClient _apiClient = ApiClient();

  Future<List<MaterialModel>> getMaterials() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.materials);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => MaterialModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadMaterial(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      await _apiClient.dio.post(ApiEndpoints.uploadMaterial, data: formData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMaterial(int id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.materials}/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MaterialModel>> searchMaterials(String query) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiEndpoints.materials}/$query',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => MaterialModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
