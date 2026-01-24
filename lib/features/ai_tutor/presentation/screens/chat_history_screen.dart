import 'package:edugenius_mobile/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
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
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Chat History'),
        backgroundColor: AppColors.getBackground(context),
        foregroundColor: AppColors.getTextPrimary(context),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _groupedSessions.isEmpty
                  ? _buildEmptyState()
                  : LiquidPullToRefresh(
                      onRefresh: _fetchSessions,
                      color: AppColors.primary,
                      backgroundColor: AppColors.getSurface(context),
                      showChildOpacityTransition: false,
                      springAnimationDurationInMilliseconds: 500,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                              SizedBox(height: 10.h),
                            ],
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
          if (result == true) _fetchSessions();
        },
        label: const Text(
          'New Chat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Iconsax.add, color: Colors.white),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDateDivider(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.withOpacity(0.2))),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.getBorder(context)),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextSecondary(context),
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
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        border: Border.all(color: AppColors.getBorder(context)),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.0.h),
          child: Text(
            'Conversation with AI Tutor • ${DateFormat('HH:mm').format(session.updatedAt)}',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.getTextSecondary(context),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Iconsax.more, color: AppColors.getTextSecondary(context)),
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
          Icon(Iconsax.clock, size: 80.r, color: AppColors.getSurface(context)),
          SizedBox(height: 16.h),
          Text(
            'No chat history yet',
            style: TextStyle(
              fontSize: 18.sp,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start a new conversation with your AI Tutor!',
            style: TextStyle(
              color: AppColors.getTextSecondary(context),
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 24.h),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12.r),
            child: InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
                if (result == true) _fetchSessions();
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.add, color: Colors.white, size: 20.r),
                    SizedBox(width: 8.w),
                    Text(
                      'New Chat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
