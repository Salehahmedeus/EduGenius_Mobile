class ChatMessageModel {
  final int? id;
  final String text;
  final bool isUser;
  final DateTime createdAt;

  ChatMessageModel({
    this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
  });

  factory ChatMessageModel.user({
    required String text,
    int? id,
    DateTime? createdAt,
  }) {
    return ChatMessageModel(
      id: id,
      text: text,
      isUser: true,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  factory ChatMessageModel.ai({
    required String text,
    int? id,
    DateTime? createdAt,
  }) {
    return ChatMessageModel(
      id: id,
      text: text,
      isUser: false,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Adapts the API response which contains both query and response in one object
  static List<ChatMessageModel> fromApiHistory(Map<String, dynamic> json) {
    final int id = json['id'] is String ? int.parse(json['id']) : json['id'];
    final DateTime createdAt = DateTime.parse(json['created_at']);

    return [
      ChatMessageModel.user(
        id: id,
        text: json['user_query'],
        createdAt: createdAt,
      ),
      ChatMessageModel.ai(
        id: id,
        text: json['ai_response'],
        createdAt: createdAt.add(
          const Duration(milliseconds: 100),
        ), // Slight offset for sorting
      ),
    ];
  }
}
