import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/utils/error_handler.dart';
import '../../data/models/chat_session_model.dart';
import '../../data/services/ai_service.dart';
import 'chat_screen.dart';

class ChatHistoryScreen extends StatefulWidget {
  final Function(int?)? onSessionSelected;
  const ChatHistoryScreen({super.key, this.onSessionSelected});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final AiService _aiService = AiService();
  List<ChatSessionModel> _sessions = [];
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
          _sessions = sessions;
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

  Future<void> _deleteSession(int id) async {
    try {
      await _aiService.deleteChat(id);
      setState(() {
        _sessions.removeWhere((s) => s.id == id);
      });
      if (mounted) CustomSnackbar.showSuccess(context, "Chat deleted");
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, ErrorHandler.parse(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color tutorBlue = Color(0xFF2196F3);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tutor History'),
        backgroundColor: tutorBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: tutorBlue))
          : _sessions.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchSessions,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _sessions.length,
                itemBuilder: (context, index) {
                  final session = _sessions[index];
                  return Dismissible(
                    key: Key(session.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Iconsax.trash, color: Colors.white),
                    ),
                    onDismissed: (direction) => _deleteSession(session.id),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE3F2FD),
                          child: Icon(Iconsax.messages_1, color: tutorBlue),
                        ),
                        title: Text(
                          session.contextName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          DateFormat(
                            'MMM dd, yyyy • HH:mm',
                          ).format(session.updatedAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        trailing: const Icon(Iconsax.arrow_right_3, size: 16),
                        onTap: () async {
                          if (widget.onSessionSelected != null) {
                            widget.onSessionSelected!(session.id);
                          } else {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatScreen(conversationId: session.id),
                              ),
                            );
                            if (result == true) _fetchSessions();
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (widget.onSessionSelected != null) {
            widget.onSessionSelected!(null);
          } else {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatScreen()),
            );
            if (result == true) _fetchSessions();
          }
        },
        label: const Text('New Chat'),
        icon: const Icon(Iconsax.add),
        backgroundColor: tutorBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.clock, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No chat history yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a new conversation with your AI Tutor!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
