import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/theme/design_tokens.dart";
import "../../core/widgets/gravity_card.dart";
import "../../core/widgets/gravity_empty_state.dart";
import "../announcements/announcement_providers.dart";
import "../announcements/models/announcement.dart";
import "chat_conversation_screen.dart";
import "chat_providers.dart";
import "models/chat_models.dart";

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Community",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: GravityColors.gray900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Studio news and group chat with your gym.",
                  style: TextStyle(fontSize: 14, color: GravityColors.gray600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const TabBar(
            labelColor: GravityColors.primary700,
            unselectedLabelColor: GravityColors.gray400,
            indicatorColor: GravityColors.primary600,
            tabs: [
              Tab(text: "Updates"),
              Tab(text: "Chat"),
            ],
          ),
          const Expanded(
            child: TabBarView(children: [_UpdatesTab(), _ChatTab()]),
          ),
        ],
      ),
    );
  }
}

class _UpdatesTab extends ConsumerWidget {
  const _UpdatesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsProvider);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(announcementsProvider);
        await ref.read(announcementsProvider.future);
      },
      child: announcementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(
          children: [
            GravityEmptyState(
              icon: Icons.error_outline,
              title: "Could not load announcements",
              description: error.toString(),
              actionLabel: "Retry",
              onAction: () => ref.invalidate(announcementsProvider),
            ),
          ],
        ),
        data: (announcements) {
          if (announcements.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                GravityEmptyState(
                  icon: Icons.campaign_outlined,
                  title: "No announcements yet",
                  description:
                      "When your studio publishes an update, it will show up here.",
                ),
              ],
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            itemCount: announcements.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _AnnouncementCard(announcement: announcements[index]);
            },
          );
        },
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    return GravityCard(
      padding: const EdgeInsets.all(GravitySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            announcement.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: GravityColors.gray900,
            ),
          ),
          if (announcement.authorName != null ||
              announcement.publishedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              [
                ?announcement.authorName,
                if (announcement.publishedAt != null)
                  "${announcement.publishedAt!.month}/${announcement.publishedAt!.day}",
              ].join(" • "),
              style: const TextStyle(
                fontSize: 12,
                color: GravityColors.gray500,
              ),
            ),
          ],
          const SizedBox(height: GravitySpacing.sm),
          Text(
            announcement.body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: GravityColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatTab extends ConsumerWidget {
  const _ChatTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(chatGroupsProvider);
    return groupsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => GravityEmptyState(
        icon: Icons.error_outline,
        title: "Chat is unavailable",
        description: error.toString(),
      ),
      data: (groups) {
        if (groups.isEmpty) {
          return const GravityEmptyState(
            icon: Icons.forum_outlined,
            title: "Chat is rolling out",
            description:
                "Your studio groups will appear here as soon as they’re enabled.",
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          itemCount: groups.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final group = groups[index];
            return _GroupTile(group: group);
          },
        );
      },
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group});

  final ChatGroup group;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(GravityRadii.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(GravityRadii.lg),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ChatConversationScreen(group: group),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GravityRadii.lg),
            border: Border.all(color: GravityColors.gray200),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: GravityColors.primary50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  group.type == "class"
                      ? Icons.fitness_center_rounded
                      : Icons.forum_rounded,
                  color: GravityColors.primary700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: GravityColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      group.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: GravityColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: GravityColors.gray400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
