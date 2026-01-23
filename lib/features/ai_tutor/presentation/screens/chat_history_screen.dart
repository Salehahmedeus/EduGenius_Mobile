import 'package:edugenius_mobile/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/utils/error_handler.dart';
import '../../data/models/chat_session_model.dart';
import '../../data/services/ai_service.dart';
import 'chat_screen.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final AiService _aiService = AiService();
  Map<String, List<ChatSessionModel>> _groupedSessions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    setState(() => _isLoading = true);
    try {
      final sessions = await _aiService.getChats();
      if (mounted) {
        setState(() {
          _groupedSessions = _groupSessions(sessions);
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

  Map<String, List<ChatSessionModel>> _groupSessions(
    List<ChatSessionModel> sessions,
  ) {
    Map<String, List<ChatSessionModel>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Sort sessions by date (newest first)
    sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    for (var session in sessions) {
      final date = DateTime(
        session.updatedAt.year,
        session.updatedAt.month,
        session.updatedAt.day,
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
      grouped[label]!.add(session);
    }
    return grouped;
  }

  Future<void> _deleteSession(int id) async {
    try {
      await _aiService.deleteChat(id);
      _fetchSessions(); // Refresh grouping
      if (mounted) CustomSnackbar.showSuccess(context, "Chat deleted");
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, ErrorHandler.parse(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _groupedSessions.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _fetchSessions,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _groupedSessions.length,
                        itemBuilder: (context, index) {
                          String label = _groupedSessions.keys.elementAt(index);
                          List<ChatSessionModel> sessions =
                              _groupedSessions[label]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDateDivider(label),
                              ...sessions.map((s) => _buildChatCard(s)),
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
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Chat History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGrey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.calendar, size: 18, color: AppColors.grey),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM yyyy').format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDivider(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.withOpacity(0.2))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGrey),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.grey,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.withOpacity(0.2))),
        ],
      ),
    );
  }

  Widget _buildChatCard(ChatSessionModel session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.lightGrey),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(conversationId: session.id),
            ),
          );
          if (result == true) _fetchSessions();
        },
        title: Text(
          session.contextName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'Conversation with AI Tutor • ${DateFormat('HH:mm').format(session.updatedAt)}',
            style: const TextStyle(fontSize: 13, color: AppColors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Iconsax.more, color: AppColors.grey),
          onSelected: (value) {
            if (value == 'delete') {
              _deleteSession(session.id);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: AppColors.error)),
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
          Icon(Iconsax.clock, size: 80, color: AppColors.lightGrey),
          const SizedBox(height: 16),
          const Text(
            'No chat history yet',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a new conversation with your AI Tutor!',
            style: TextStyle(color: AppColors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
              if (result == true) _fetchSessions();
            },
            icon: const Icon(Iconsax.add, color: Colors.white),
            label: const Text(
              'New Chat',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
