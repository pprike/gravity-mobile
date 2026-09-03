import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/api/error_messages.dart";
import "../../core/theme/gravity_palette.dart";
import "../../core/widgets/gravity_empty_state.dart";
import "../../core/widgets/gravity_feedback.dart";
import "../scheduling/scheduling_formatters.dart";
import "chat_providers.dart";
import "models/chat_models.dart";

class ChatConversationScreen extends ConsumerStatefulWidget {
  const ChatConversationScreen({super.key, required this.group});

  final ChatGroup group;

  @override
  ConsumerState<ChatConversationScreen> createState() =>
      _ChatConversationScreenState();
}

class _ChatConversationScreenState
    extends ConsumerState<ChatConversationScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(chatRepositoryProvider)
          .sendMessage(groupId: widget.group.id, body: text);
      _controller.clear();
      ref.invalidate(chatMessagesProvider(widget.group.id));
    } catch (error) {
      if (mounted) {
        GravityFeedback.showSnack(
          context,
          message: friendlyErrorMessage(
            error,
            fallback: "Message didn’t send. Please try again.",
          ),
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.group.id));

    return Scaffold(
      backgroundColor: context.palette.surfaceMuted,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.name),
            Text(
              widget.group.subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => GravityEmptyState(
                icon: Icons.error_outline,
                title: "Couldn't load messages",
                description: friendlyErrorMessage(error),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return const GravityEmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: "Start the conversation",
                    description:
                        "Say hi to your studio. Messages stay in this group.",
                  );
                }
                // Reversed so the newest message is always in view without
                // chasing it with a post-frame scroll.
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _Bubble(
                      message: messages[messages.length - 1 - index],
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: context.palette.surface,
                border: Border(top: BorderSide(color: context.palette.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: "Message ${widget.group.name}",
                        filled: true,
                        fillColor: context.palette.surfaceMuted,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    tooltip: "Send message",
                    style: IconButton.styleFrom(
                      backgroundColor: context.palette.accent,
                      foregroundColor: context.palette.onAccent,
                      minimumSize: const Size(44, 44),
                    ),
                    icon: _sending
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.palette.onAccent,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: mine ? context.palette.accent : context.palette.surface,
            borderRadius: BorderRadius.circular(16).copyWith(
              bottomRight: mine ? const Radius.circular(4) : null,
              bottomLeft: mine ? null : const Radius.circular(4),
            ),
            border: mine ? null : Border.all(color: context.palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!mine)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    message.senderName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.palette.accentStrong,
                    ),
                  ),
                ),
              Text(
                message.body,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: mine
                      ? context.palette.onAccent
                      : context.palette.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  SchedulingFormatters.timeOfDay(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: mine ? Colors.white70 : context.palette.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
