import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:edugenius_mobile/core/utils/error_handler.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../data/models/chat_message_model.dart';
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

  @override
  void initState() {
    super.initState();
    _activeConversationId = widget.conversationId;
    if (_activeConversationId != null) {
      _fetchHistory();
    }
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
    if (_activeConversationId == null) return;
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

  void _scrollToBottom() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        try {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } catch (_) {}
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
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.maybePop(context, true),
        ),
        title: Text(_activeConversationId != null ? 'Chat' : 'New Chat'),
        backgroundColor: AppColors.getBackground(context),
        foregroundColor: AppColors.getTextPrimary(context),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: _activeConversationId != null ? _fetchHistory : null,
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          Navigator.pop(context, true);
        },
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _messages.isEmpty
                  ? _buildEmptyState()
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
            _buildInputArea(AppColors.primary),
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.message_question,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'How can I help you today?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask anything about your study materials',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondary(context),
            ),
          ),
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
          color: isUser ? AppColors.primary : AppColors.getSurface(context),
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
                style: const TextStyle(color: AppColors.white, fontSize: 16),
              )
            : MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 16,
                  ),
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
          color: AppColors.getSurface(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Thinking...',
          style: TextStyle(
            color: AppColors.getTextSecondary(context),
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(Color themeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.getBackground(context),
        border: Border(top: BorderSide(color: AppColors.getBorder(context))),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextPrimary(context),
                        ),
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
                color: AppColors.getSurface(context),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.getBorder(context)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getTextPrimary(context).withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Iconsax.paperclip,
                          color: AppColors.getTextSecondary(context),
                        ),
                        onPressed: _pickFile,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          maxLines: null,
                          style: TextStyle(
                            color: AppColors.getTextPrimary(context),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Message to AI Tutor...',
                            hintStyle: TextStyle(
                              color: AppColors.getTextSecondary(context),
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
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
                          color: AppColors.getTextSecondary(context),
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          Iconsax.microphone_2,
                          color: AppColors.getTextSecondary(context),
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 4),
                      Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          onTap: _sendMessage,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Send',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Iconsax.send_1,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ],
                            ),
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
}
