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
    return ChatSessionModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      contextName: json['context_name'] ?? 'New Chat',
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
