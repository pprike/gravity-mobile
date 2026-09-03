import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/api/error_messages.dart";
import "../../core/push/push_service.dart";
import "../../core/theme/design_tokens.dart";
import "../../core/theme/gravity_palette.dart";
import "../../core/widgets/gravity_button.dart";
import "../../core/widgets/gravity_card.dart";
import "../../core/widgets/gravity_empty_state.dart";
import "../../core/widgets/gravity_feedback.dart";
import "models/notification_models.dart";
import "notification_providers.dart";

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  NotificationPreferences? _draft;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(notificationPreferencesProvider);
    return Scaffold(
      backgroundColor: context.palette.surfaceMuted,
      appBar: AppBar(title: const Text("Notification settings")),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => GravityEmptyState(
          icon: Icons.error_outline,
          title: "Couldn't load preferences",
          description: friendlyErrorMessage(error),
          actionLabel: "Retry",
          onAction: () => ref.invalidate(notificationPreferencesProvider),
        ),
        data: (prefs) {
          final draft = _draft ?? prefs;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                "Choose what reaches your phone. You can change this anytime.",
                style: TextStyle(
                  fontSize: 14,
                  color: context.palette.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const _SystemPermissionNotice(),
              GravityCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _PrefTile(
                      title: "Announcements",
                      subtitle: "Studio news and organization-wide updates.",
                      value: draft.announcements,
                      onChanged: (value) => setState(
                        () => _draft = draft.copyWith(announcements: value),
                      ),
                    ),
                    const Divider(height: 1),
                    _PrefTile(
                      title: "Class reminders",
                      subtitle: "Bookings, waitlist moves, and class messages.",
                      value: draft.classMessages,
                      onChanged: (value) => setState(
                        () => _draft = draft.copyWith(classMessages: value),
                      ),
                    ),
                    const Divider(height: 1),
                    _PrefTile(
                      title: "Billing alerts",
                      subtitle: "Receipts, failed charges, and renewals.",
                      value: draft.marketing,
                      onChanged: (value) => setState(
                        () => _draft = draft.copyWith(marketing: value),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GravityButton(
                label: "Save preferences",
                isLoading: _saving,
                fullWidth: true,
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        try {
                          await ref
                              .read(notificationRepositoryProvider)
                              .updatePreferences(draft);
                          ref.invalidate(notificationPreferencesProvider);
                          if (context.mounted) {
                            GravityFeedback.showSnack(
                              context,
                              message: "Preferences saved",
                            );
                          }
                        } catch (error) {
                          if (context.mounted) {
                            GravityFeedback.showSnack(
                              context,
                              message: friendlyErrorMessage(
                                error,
                                fallback:
                                    "Couldn’t save your preferences. Please try again.",
                              ),
                              error: true,
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _saving = false);
                        }
                      },
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Preferences below are moot if the OS itself is blocking us, so say so.
class _SystemPermissionNotice extends ConsumerWidget {
  const _SystemPermissionNotice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorized = ref.watch(pushAuthorizedProvider).valueOrNull;
    if (authorized != false) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.palette.warningSurface,
          borderRadius: BorderRadius.circular(GravityRadii.lg),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 18,
              color: context.palette.warning,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Notifications are turned off for Gravity in your phone’s "
                "settings. Turn them on there to get these alerts.",
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: context.palette.warning,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrefTile extends StatelessWidget {
  const _PrefTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: context.palette.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: context.palette.textSecondary),
      ),
      value: value,
      activeThumbColor: context.palette.accent,
      onChanged: onChanged,
    );
  }
}
