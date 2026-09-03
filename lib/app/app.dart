import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core/theme/app_theme.dart";
import "../core/theme/studio_imagery.dart";
import "../core/theme/text_scaling.dart";
import "../core/theme/theme_mode_controller.dart";
import "router.dart";

class GravityApp extends ConsumerWidget {
  const GravityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: "Gravity",
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        final media = MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.textScalerOf(
            context,
          ).clamp(minScaleFactor: 1.0, maxScaleFactor: kMaxTextScale),
        );
        const maxWidth = 430.0;
        if (media.size.width <= maxWidth) {
          return MediaQuery(data: media, child: content);
        }
        final frameHeight = math.min(media.size.height - 32, 900.0);
        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0xFF0B1C1A)),
            Image.asset(
              StudioImagery.hero,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: Color(0xFF0B1C1A)),
            ),
            const ColoredBox(color: Color(0xB30B1C1A)),
            Center(
              child: SizedBox(
                width: maxWidth,
                height: frameHeight,
                child: MediaQuery(
                  data: media.copyWith(size: Size(maxWidth, frameHeight)),
                  child: Material(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 24,
                    shadowColor: const Color(0x66000000),
                    borderRadius: BorderRadius.circular(28),
                    clipBehavior: Clip.antiAlias,
                    child: content,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
