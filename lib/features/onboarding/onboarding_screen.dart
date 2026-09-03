import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../core/theme/gravity_palette.dart";
import "../../core/theme/theme_mode_controller.dart";
import "../../core/widgets/gravity_button.dart";

const _kOnboardingDoneKey = "onboarding_done";

/// Returns true if this member has not yet completed onboarding.
Future<bool> needsOnboarding(SharedPreferences? prefs) async {
  return !(prefs?.getBool(_kOnboardingDoneKey) ?? false);
}

Future<void> markOnboardingDone(SharedPreferences? prefs) async {
  await prefs?.setBool(_kOnboardingDoneKey, true);
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.fitness_center_rounded,
      title: "Welcome to Gravity",
      body:
          "Book classes, track your progress, and stay connected with your studio — all in one place.",
    ),
    _OnboardingPage(
      icon: Icons.calendar_today_rounded,
      title: "Book in seconds",
      body:
          "Tap any class on the schedule to reserve your spot. We'll remind you before it starts.",
    ),
    _OnboardingPage(
      icon: Icons.qr_code_2_rounded,
      title: "Check in with a tap",
      body:
          "Show your QR code at the front desk or use it at the self-check-in kiosk. No card needed.",
    ),
    _OnboardingPage(
      icon: Icons.notifications_outlined,
      title: "Stay in the loop",
      body:
          "Get notified when your waitlisted spot opens up, and when the studio has news for you.",
    ),
  ];

  Future<void> _finish() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await markOnboardingDone(prefs);
    if (mounted) context.go("/");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      backgroundColor: context.palette.surfaceMuted,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  "Skip",
                  style: TextStyle(color: context.palette.textSecondary),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  for (int i = 0; i < _pages.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 6),
                      width: i == _page ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? context.palette.accent
                            : context.palette.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  const Spacer(),
                  GravityButton(
                    label: isLast ? "Get started" : "Next",
                    icon: isLast ? null : Icons.arrow_forward_rounded,
                    onPressed: isLast
                        ? _finish
                        : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: context.palette.accentSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 44, color: context.palette.accent),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: context.palette.textPrimary,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.55,
              color: context.palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
