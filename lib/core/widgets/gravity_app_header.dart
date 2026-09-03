import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/providers/app_providers.dart";
import "../../features/branding/branding.dart";
import "../theme/gravity_palette.dart";

class GravityAppHeader extends ConsumerWidget {
  const GravityAppHeader({
    super.key,
    this.onNotifications,
    this.trailing,
    this.unreadCount = 0,
  });

  final VoidCallback? onNotifications;
  final Widget? trailing;
  final int unreadCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(tenantBrandingProvider).valueOrNull;
    final demo = ref.watch(isDemoModeProvider);
    final name = demo
        ? "IRON PEAK"
        : (branding?.organizationName ?? "Gravity").toUpperCase();

    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: context.palette.surface,
        border: Border(bottom: BorderSide(color: context.palette.border)),
      ),
      child: Row(
        children: [
          if (branding?.logoUrl != null && branding!.logoUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  branding.logoUrl!,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.terrain_rounded,
                    size: 24,
                    color: context.palette.accent,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.terrain_rounded,
                size: 24,
                color: context.palette.accent,
              ),
            ),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: context.palette.textPrimary,
              ),
            ),
          ),
          trailing ??
              Semantics(
                button: true,
                label: unreadCount > 0
                    ? "Notifications, $unreadCount unread"
                    : "Notifications",
                child: Tooltip(
                  message: "Notifications",
                  child: Material(
                    color: context.palette.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: onNotifications,
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Center(
                              child: Icon(
                                Icons.notifications_none_rounded,
                                size: 20,
                                color: context.palette.textPrimary,
                              ),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: context.palette.danger,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
