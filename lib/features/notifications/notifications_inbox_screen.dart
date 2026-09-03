import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/api/error_messages.dart";
import "../../core/theme/design_tokens.dart";
import "../../core/theme/gravity_palette.dart";
import "../../core/widgets/gravity_empty_state.dart";
import "../../core/widgets/gravity_feedback.dart";
import "../../core/utils/relative_time.dart";
import "models/notification_models.dart";
import "notification_providers.dart";

class NotificationsInboxScreen extends ConsumerWidget {
  const NotificationsInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxAsync = ref.watch(inboxProvider);

    return Scaffold(
      backgroundColor: context.palette.surfaceMuted,
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          TextButton(
            onPressed: (inboxAsync.valueOrNull?.unreadCount ?? 0) == 0
                ? null
                : () async {
                    try {
                      await ref
                          .read(notificationRepositoryProvider)
                          .markAllRead();
                      ref.invalidate(inboxProvider);
                    } catch (error) {
                      if (context.mounted) {
                        GravityFeedback.showSnack(
                          context,
                          message: friendlyErrorMessage(error),
                          error: true,
                        );
                      }
                    }
                  },
            child: const Text("Mark all read"),
          ),
        ],
      ),
      body: inboxAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => GravityEmptyState(
          icon: Icons.error_outline,
          title: "Couldn't load updates",
          description: friendlyErrorMessage(error),
          actionLabel: "Retry",
          onAction: () => ref.invalidate(inboxProvider),
        ),
        data: (inbox) {
          if (inbox.items.isEmpty) {
            return const GravityEmptyState(
              icon: Icons.notifications_none_rounded,
              title: "You're all caught up",
              description: "Class reminders and studio news will land here.",
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            itemCount: inbox.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = inbox.items[index];
              return _InboxCard(
                notification: item,
                onTap: () async {
                  if (!item.read) {
                    await ref
                        .read(notificationRepositoryProvider)
                        .markRead(item.id);
                    ref.invalidate(inboxProvider);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _InboxCard extends StatelessWidget {
  const _InboxCard({required this.notification, required this.onTap});

  final InboxNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.surface,
      borderRadius: BorderRadius.circular(GravityRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GravityRadii.lg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GravityRadii.lg),
            border: Border.all(color: context.palette.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.read
                      ? context.palette.surfaceMuted
                      : context.palette.accentSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification.category == "classMessages"
                      ? Icons.event_available_rounded
                      : Icons.campaign_outlined,
                  color: context.palette.accentStrong,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.read
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                              color: context.palette.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          relativeTimeLabel(notification.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: context.palette.textMuted,
                          ),
                        ),
                        if (!notification.read) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: context.palette.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: context.palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
