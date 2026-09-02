import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/theme/design_tokens.dart";
import "../../core/widgets/gravity_empty_state.dart";
import "models/notification_models.dart";
import "notification_providers.dart";

class NotificationsInboxScreen extends ConsumerWidget {
  const NotificationsInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxAsync = ref.watch(inboxProvider);

    return Scaffold(
      backgroundColor: GravityColors.neutral50,
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllRead();
              ref.invalidate(inboxProvider);
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
          description: error.toString(),
          actionLabel: "Retry",
          onAction: () => ref.invalidate(inboxProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const GravityEmptyState(
              icon: Icons.notifications_none_rounded,
              title: "You're all caught up",
              description: "Class reminders and studio news will land here.",
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(GravityRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GravityRadii.lg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GravityRadii.lg),
            border: Border.all(color: GravityColors.gray200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.read
                      ? GravityColors.neutral50
                      : GravityColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification.category == "classMessages"
                      ? Icons.event_available_rounded
                      : Icons.campaign_outlined,
                  color: GravityColors.primary700,
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
                              color: GravityColors.gray900,
                            ),
                          ),
                        ),
                        if (!notification.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: GravityColors.primary600,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: GravityColors.gray600,
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
