import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../features/branding/branding.dart";
import "../theme/design_tokens.dart";

class GravityAppHeader extends ConsumerWidget {
  const GravityAppHeader({super.key, this.onNotifications, this.trailing});

  final VoidCallback? onNotifications;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(tenantBrandingProvider).valueOrNull;
    final name = (branding?.organizationName ?? "Gravity").toUpperCase();

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: GravityColors.gray200)),
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
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.terrain_rounded,
                    size: 24,
                    color: GravityColors.gray900,
                  ),
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                Icons.terrain_rounded,
                size: 24,
                color: GravityColors.gray900,
              ),
            ),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: GravityColors.gray900,
              ),
            ),
          ),
          trailing ??
              GestureDetector(
                onTap: onNotifications,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: GravityColors.neutral50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    size: 20,
                    color: GravityColors.gray900,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
