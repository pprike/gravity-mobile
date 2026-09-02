import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/theme/design_tokens.dart";
import "../../core/widgets/gravity_card.dart";
import "../../core/widgets/gravity_empty_state.dart";
import "announcement_providers.dart";
import "models/announcement.dart";

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        const Text(
          "Community",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: GravityColors.gray900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Studio announcements and updates from your gym.",
          style: TextStyle(fontSize: 14, color: GravityColors.gray600),
        ),
        const SizedBox(height: GravitySpacing.lg),
        announcementsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => GravityEmptyState(
            icon: Icons.error_outline,
            title: "Could not load announcements",
            description: error.toString(),
            actionLabel: "Retry",
            onAction: () => ref.invalidate(announcementsProvider),
          ),
          data: (announcements) {
            if (announcements.isEmpty) {
              return const GravityEmptyState(
                icon: Icons.campaign_outlined,
                title: "No announcements yet",
                description:
                    "When your studio publishes an update, it will show up here.",
              );
            }
            return Column(
              children: [
                for (final item in announcements) ...[
                  _AnnouncementCard(announcement: item),
                  const SizedBox(height: GravitySpacing.md),
                ],
              ],
            );
          },
        ),
      ],
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
                if (announcement.authorName != null) announcement.authorName,
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
