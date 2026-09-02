import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core/theme/app_theme.dart";
import "router.dart";

class GravityApp extends ConsumerWidget {
  const GravityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: "Gravity",
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        final media = MediaQuery.of(context);
        const maxWidth = 430.0;
        if (media.size.width <= maxWidth) return content;
        return ColoredBox(
          color: const Color(0xFFE5E7EB),
          child: Center(
            child: SizedBox(
              width: maxWidth,
              height: media.size.height,
              child: MediaQuery(
                data: media.copyWith(size: Size(maxWidth, media.size.height)),
                child: Material(
                  color: Colors.white,
                  elevation: 12,
                  shadowColor: const Color(0x33000000),
                  child: content,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
