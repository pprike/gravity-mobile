import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/api/error_messages.dart";
import "../../core/auth/auth_repository.dart";
import "../../core/providers/app_providers.dart";
import "../../core/theme/design_tokens.dart";
import "../../core/theme/gravity_palette.dart";
import "../../core/theme/text_scaling.dart";
import "../../core/theme/studio_imagery.dart";
import "../../core/widgets/gravity_feedback.dart";

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _defaultTenant = "tenant-a";

  final _emailController = TextEditingController(
    text: kDebugMode ? "member@tenant-a.com" : "",
  );
  final _passwordController = TextEditingController(
    text: kDebugMode ? "Password123!" : "",
  );
  final _tenantController = TextEditingController(text: _defaultTenant);
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showStudio = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tenantController.dispose();
    super.dispose();
  }

  String _tenantDisplayName() {
    final slug = _tenantController.text.trim().isEmpty
        ? _defaultTenant
        : _tenantController.text.trim();
    const aliases = {
      "tenant-a": "Iron Peak",
      "iron-peak": "Iron Peak",
      "ironpeak": "Iron Peak",
    };
    final mapped = aliases[slug.toLowerCase()];
    if (mapped != null) return mapped;
    return slug
        .split("-")
        .map(
          (part) =>
              part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
        )
        .join(" ");
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = "Enter the email you use at the studio.");
      return;
    }
    if (!email.contains("@") || !email.contains(".")) {
      setState(() => _error = "Enter a valid email address.");
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() {
        _error = kDebugMode
            ? "Enter your password. Local studio accounts use Password123!"
            : "Enter your password.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref
          .read(authSessionProvider.notifier)
          .login(
            LoginRequest(
              tenantSlug: _tenantController.text.trim().isEmpty
                  ? _defaultTenant
                  : _tenantController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    } catch (error) {
      setState(
        () => _error = friendlyErrorMessage(
          error,
          fallback: "Unable to sign in. Check your credentials.",
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exploreDemo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ref.read(authSessionProvider.notifier).loginDemo();
    } catch (_) {
      setState(() => _error = "Couldn't open the demo studio.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _requestPasswordReset(BuildContext sheetContext) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(
        () => _error = "Enter your email first, then tap Forgot password.",
      );
      return;
    }

    try {
      await ref
          .read(authRepositoryProvider)
          .forgotPassword(
            email: email,
            tenantSlug: _tenantController.text.trim().isEmpty
                ? _defaultTenant
                : _tenantController.text.trim(),
          );
      if (!mounted) return;
      if (sheetContext.mounted) Navigator.pop(sheetContext);
      GravityFeedback.showSnack(
        context,
        message:
            "If that email is on file, your studio will send a reset link shortly.",
      );
    } catch (error) {
      if (!mounted) return;
      if (sheetContext.mounted) Navigator.pop(sheetContext);
      setState(
        () => _error = friendlyErrorMessage(
          error,
          fallback: "Couldn’t request a reset right now.",
        ),
      );
    }
  }

  void _showForgotPassword() {
    if (_emailController.text.trim().isEmpty) {
      setState(
        () => _error = "Enter your email first, then tap Forgot password.",
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        var sending = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.palette.border,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Reset your password",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: context.palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We’ll email a reset link to ${_emailController.text.trim()} "
                    "if it belongs to your studio. Check spam if it doesn’t "
                    "arrive within a few minutes.",
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: context.palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: context.scaled(48),
                    child: ElevatedButton(
                      onPressed: sending
                          ? null
                          : () async {
                              setSheetState(() => sending = true);
                              await _requestPasswordReset(sheetContext);
                            },
                      child: sending
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.palette.onAccent,
                              ),
                            )
                          : const Text("Send reset link"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenantName = _tenantDisplayName();
    final enableDemo = ref.watch(appConfigProvider).enableDemo;

    return Scaffold(
      backgroundColor: context.palette.surface,
      body: Column(
        children: [
          _LoginHero(tenantName: tenantName),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Welcome back",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: context.palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Sign in to your $tenantName account",
                      style: TextStyle(
                        fontSize: 14,
                        color: context.palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _LoginField(
                      label: "Email Address",
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: 16),
                    _LoginField(
                      label: "Password",
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _submit(),
                      suffix: TextButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(48, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                          foregroundColor: context.palette.accent,
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(_obscurePassword ? "Show" : "Hide"),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPassword,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(48, 44),
                          visualDensity: VisualDensity.compact,
                          foregroundColor: context.palette.accent,
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text("Forgot password?"),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () =>
                            setState(() => _showStudio = !_showStudio),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(48, 44),
                          visualDensity: VisualDensity.compact,
                          foregroundColor: context.palette.textSecondary,
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(
                          _showStudio
                              ? "Hide studio ID"
                              : "Sign in to a different studio",
                        ),
                      ),
                    ),
                    if (_showStudio) ...[
                      const SizedBox(height: 12),
                      _LoginField(
                        label: "Studio ID",
                        controller: _tenantController,
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Semantics(
                        liveRegion: true,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: context.palette.dangerSurface,
                            borderRadius: BorderRadius.circular(
                              GravityRadii.md,
                            ),
                          ),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: context.palette.danger,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  button: true,
                  label: _isLoading ? "Signing in" : "Sign In",
                  child: SizedBox(
                    height: context.scaled(52),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.palette.accent,
                        foregroundColor: context.palette.onAccent,
                        disabledBackgroundColor: context.palette.accent
                            .withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            GravityRadii.button,
                          ),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.palette.onAccent,
                              ),
                            )
                          : const Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
                if (enableDemo)
                  TextButton(
                    onPressed: _isLoading ? null : _exploreDemo,
                    child: Text(
                      "Explore demo studio",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.palette.accentStrong,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: SafeArea(top: false, child: _SupportFooter()),
          ),
        ],
      ),
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero({required this.tenantName});

  final String tenantName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.scaled(188).clamp(160.0, 248.0),
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            StudioImagery.hero,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const ColoredBox(color: Color(0xFF111827)),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x660B1C1A), Color(0xE6111827)],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.terrain_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        tenantName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    "Ready when you are.",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                      letterSpacing: -0.6,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.palette.textPrimary,
          ),
        ),
        const SizedBox(height: GravitySpacing.sm),
        SizedBox(
          height: context.scaled(48),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            autocorrect: keyboardType == TextInputType.emailAddress
                ? false
                : true,
            enableSuggestions: keyboardType != TextInputType.emailAddress,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            autofillHints: autofillHints,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: context.palette.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: context.palette.surfaceMuted,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              suffixIcon: suffix == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: suffix,
                    ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GravityRadii.md),
                borderSide: BorderSide(color: context.palette.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GravityRadii.md),
                borderSide: BorderSide(color: context.palette.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GravityRadii.md),
                borderSide: BorderSide(
                  color: context.palette.accent,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SupportFooter extends StatelessWidget {
  const _SupportFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Need help? Contact your studio front desk.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: context.palette.textMuted,
          ),
        ),
      ],
    );
  }
}
