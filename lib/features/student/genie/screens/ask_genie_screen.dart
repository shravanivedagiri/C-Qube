import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/models/genie_message_model.dart';
import 'package:c_qube/state/student_state.dart';

class AskGenieScreen extends StatefulWidget {
  const AskGenieScreen({super.key});

  @override
  State<AskGenieScreen> createState() => _AskGenieScreenState();
}

class _AskGenieScreenState extends State<AskGenieScreen> {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<String> _starterPrompts = [
    'What workshops are happening this week?',
    'Which coding clubs should I join for App Development?',
    'How do I apply for club recruitment drives?',
    'Show me beginner-friendly hackathons on campus',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _handleSend([String? presetText]) async {
    final text = presetText ?? _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    final studentState = Provider.of<StudentState>(context, listen: false);

    setState(() => _isTyping = true);
    _scrollToBottom();

    await studentState.askGenie(text);

    if (mounted) {
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final studentState = Provider.of<StudentState>(context);
    final messages = studentState.genieMessages;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.primary],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ask Genie AI',
                  style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Campus AI Assistant',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Starter Prompts Horizontal Bar (If short conversation history)
          if (messages.length <= 2)
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _starterPrompts.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final prompt = _starterPrompts[index];
                  return ActionChip(
                    avatar: const Icon(Icons.auto_awesome, size: 14, color: AppColors.secondary),
                    label: Text(prompt, style: AppTypography.labelSmall),
                    backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                    side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    onPressed: () => _handleSend(prompt),
                  );
                },
              ),
            ),
          const Divider(height: 1),

          // Messages List
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _buildMessageBubble(msg, isDark);
              },
            ),
          ),

          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Text(
                    'Genie is finding campus answers...',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.secondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Text Input Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              border: Border(
                top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask Genie anything about clubs, events...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _handleSend(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(GenieMessageModel msg, bool isDark) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: msg.isUser
              ? AppColors.primary
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 16),
          ),
          border: msg.isUser
              ? null
              : Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!msg.isUser)
              Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 14, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Text(
                    'Genie AI',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            if (!msg.isUser) const SizedBox(height: 6),
            Text(
              msg.text,
              style: AppTypography.bodyMedium.copyWith(
                color: msg.isUser
                    ? Colors.white
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                height: 1.45,
              ),
            ),

            // Quick reply chips if provided by Genie
            if (!msg.isUser && msg.quickReplies.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: msg.quickReplies.map((reply) {
                  return ActionChip(
                    label: Text(reply, style: AppTypography.labelSmall.copyWith(color: AppColors.secondary)),
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                    side: BorderSide.none,
                    onPressed: () => _handleSend(reply),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
