import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:edugenius_mobile/core/utils/error_handler.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/chat_session_model.dart';
import '../../data/services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  final int? conversationId;

  const ChatScreen({super.key, this.conversationId});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final AiService _aiService = AiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  bool _isThinking = false;
  int? _activeConversationId;
  File? _attachedFile;

  List<ChatSessionModel> _sessions = [];
  bool _isSessionsLoading = false;

  @override
  void initState() {
    super.initState();
    _activeConversationId = widget.conversationId;
    if (_activeConversationId != null) {
      _fetchHistory();
    }
    _fetchSessions(); // Always fetch for drawer
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void loadChat(int? id) {
    setState(() {
      _activeConversationId = id;
      _messages = [];
      _attachedFile = null;
    });
    if (id != null) {
      _fetchHistory();
    }
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final history = await _aiService.getMessages(_activeConversationId!);
      if (mounted) {
        setState(() {
          _messages = history;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomSnackbar.showError(context, ErrorHandler.parse(e));
      }
    }
  }

  Future<void> _fetchSessions() async {
    setState(() => _isSessionsLoading = true);
    try {
      final sessions = await _aiService.getChats();
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isSessionsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSessionsLoading = false);
      }
    }
  }

  Future<void> _deleteSession(int id) async {
    try {
      await _aiService.deleteChat(id);
      setState(() {
        _sessions.removeWhere((s) => s.id == id);
        if (_activeConversationId == id) {
          _activeConversationId = null;
          _messages = [];
        }
      });
      if (mounted) CustomSnackbar.showSuccess(context, "Chat deleted");
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, ErrorHandler.parse(e));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _attachedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, "Error picking file: $e");
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _attachedFile == null) return;

    final userMsg = ChatMessageModel.user(
      text: text.isEmpty ? "Analyzed file" : text,
    );

    setState(() {
      _messages.add(userMsg);
      _isThinking = true;
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      final response = await _aiService.sendMessage(
        query: text.isEmpty ? "Please analyze this file" : text,
        conversationId: _activeConversationId,
        file: _attachedFile,
      );

      if (mounted) {
        setState(() {
          _isThinking = false;
          _attachedFile = null;
          _activeConversationId ??= response['conversation_id'];
          _messages.add(ChatMessageModel.ai(text: response['response']));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isThinking = false);
        CustomSnackbar.showError(context, ErrorHandler.parse(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color tutorBlue = Color(0xFF2196F3);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: tutorBlue,
        foregroundColor: Colors.white,
        title: const Text('AI Tutor'),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Iconsax.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit),
            tooltip: 'New Chat',
            onPressed: () {
              loadChat(null);
              _fetchSessions();
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: _activeConversationId != null ? _fetchHistory : null,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: tutorBlue),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isThinking ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _buildThinkingIndicator();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),
          _buildInputArea(tutorBlue),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message) {
    bool isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF2196F3) : const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: isUser
            ? Text(
                message.text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              )
            : MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(color: Colors.black87, fontSize: 16),
                ),
              ),
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Thinking...',
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildInputArea(Color themeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_attachedFile != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Chip(
                      avatar: Icon(
                        Iconsax.document,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        _attachedFile!.path.split('/').last,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onDeleted: () => setState(() => _attachedFile = null),
                      backgroundColor: AppColors.primaryLight,
                      deleteIconColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Iconsax.paperclip, color: AppColors.grey),
                        onPressed: _pickFile,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Message to AI Tutor...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Iconsax.emoji_happy,
                          color: Colors.blueGrey.shade700,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          Iconsax.microphone_2,
                          color: Colors.blueGrey.shade700,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton.icon(
                        onPressed: _sendMessage,
                        icon: const Text(
                          'Send',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        label: const Icon(
                          Iconsax.send_1,
                          color: Colors.white,
                          size: 20,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF2196F3)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.messages_1, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'Chat History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Iconsax.add, color: Color(0xFF2196F3)),
            title: const Text(
              'New Chat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              loadChat(null);
            },
          ),
          const Divider(),
          Expanded(
            child: _isSessionsLoading
                ? const Center(child: CircularProgressIndicator())
                : _sessions.isEmpty
                ? _buildDrawerEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _sessions.length,
                    itemBuilder: (context, index) {
                      final session = _sessions[index];
                      final isActive = session.id == _activeConversationId;
                      return ListTile(
                        selected: isActive,
                        selectedTileColor: Colors.blue.withOpacity(0.05),
                        leading: Icon(
                          Iconsax.message_text,
                          color: isActive
                              ? const Color(0xFF2196F3)
                              : Colors.grey,
                        ),
                        title: Text(
                          session.contextName,
                          style: TextStyle(
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isActive
                                ? const Color(0xFF2196F3)
                                : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          DateFormat('MMM dd').format(session.updatedAt),
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Iconsax.trash,
                            size: 18,
                            color: Colors.grey,
                          ),
                          onPressed: () => _deleteSession(session.id),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          loadChat(session.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.clock, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text('No history yet', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
