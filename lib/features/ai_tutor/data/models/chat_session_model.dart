class ChatSessionModel {
  final int id;
  final String contextName;
  final DateTime updatedAt;

  ChatSessionModel({
    required this.id,
    required this.contextName,
    required this.updatedAt,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    final updatedAtStr = json['updated_at'] as String?;
    final updatedAt = updatedAtStr != null
        ? DateTime.parse(updatedAtStr)
        : DateTime.now();

    return ChatSessionModel(
      id: json['id'] is String
          ? (int.tryParse(json['id']) ?? 0)
          : (json['id'] ?? 0),
      contextName: json['context_name'] ?? 'New Chat',
      updatedAt: updatedAt,
    );
  }
}
