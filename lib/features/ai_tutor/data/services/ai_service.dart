import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/chat_session_model.dart';
import '../models/chat_message_model.dart';

class AiService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ChatSessionModel>> getChats() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.aiChats);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => ChatSessionModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ChatMessageModel>> getMessages(int id) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiEndpoints.aiHistory}/$id',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final List<ChatMessageModel> messages = [];
        for (var item in data) {
          messages.addAll(ChatMessageModel.fromApiHistory(item));
        }
        // Filter out empty texts if any and sort by time
        return messages..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteChat(int id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.aiChats}/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String query,
    int? conversationId,
    File? file,
  }) async {
    try {
      Map<String, dynamic> body = {'query': query};

      if (conversationId != null) {
        body['conversation_id'] = conversationId;
      }

      if (file != null) {
        String fileName = file.path.split('/').last;
        body['file'] = await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        );
      }

      FormData formData = FormData.fromMap(body);

      final response = await _apiClient.dio.post(
        ApiEndpoints.aiAsk,
        data: formData,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
