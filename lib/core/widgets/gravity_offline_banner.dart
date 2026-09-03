import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../network/connectivity_providers.dart";
import "../theme/gravity_palette.dart";

/// Persistent strip shown while the device has no network interface.
class GravityOfflineBanner extends ConsumerWidget {
  const GravityOfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Treat "unknown" as online so a connectivity plugin failure never blocks
    // the UI with a false alarm.
    final online = ref.watch(isOnlineProvider).valueOrNull ?? true;

    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: online
          ? const SizedBox(width: double.infinity)
          : Semantics(
              liveRegion: true,
              child: Container(
                width: double.infinity,
                color: context.palette.inverseSurface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 16,
                      color: context.palette.onInverseSurface,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "You’re offline. Showing the last thing we loaded.",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.palette.onInverseSurface,
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
