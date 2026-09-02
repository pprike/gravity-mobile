import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/api/api_exception.dart";
import "../../core/auth/auth_repository.dart";
import "../../core/providers/app_providers.dart";
import "../../core/theme/design_tokens.dart";

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _defaultTenant = "tenant-a";

  final _emailController = TextEditingController(text: "member@tenant-a.com");
  final _passwordController = TextEditingController();
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
    return slug
        .split("-")
        .map(
          (part) =>
              part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
        )
        .join(" ");
  }

  Future<void> _submit() async {
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
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } catch (_) {
      setState(() => _error = "Unable to sign in. Check your credentials.");
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

  void _showForgotPassword() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
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
                    color: GravityColors.gray200,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Reset your password",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: GravityColors.gray900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Password resets are handled by your studio. Email the front desk and they’ll send a new invite link.",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: GravityColors.gray600,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Got it"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: GravitySpacing.lg),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      _BrandingHeader(tenantName: _tenantDisplayName()),
                      const SizedBox(height: 32),
                      _LoginField(
                        label: "Email Address",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 20),
                      _LoginField(
                        label: "Password",
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => _submit(),
                        suffix: GestureDetector(
                          onTap: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          child: Text(
                            _obscurePassword ? "Show" : "Hide",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: GravityColors.primary600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () =>
                              setState(() => _showStudio = !_showStudio),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _showStudio
                                ? "Hide studio ID"
                                : "Sign in to a different studio",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: GravityColors.gray500,
                            ),
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
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPassword,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "Forgot password?",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: GravityColors.primary600,
                            ),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: GravitySpacing.md),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: GravityColors.danger50,
                            borderRadius: BorderRadius.circular(
                              GravityRadii.md,
                            ),
                          ),
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: GravityColors.danger700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GravityColors.primary600,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: GravityColors.primary600
                            .withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            GravityRadii.button,
                          ),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
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
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _exploreDemo,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: GravityColors.gray900,
                        side: const BorderSide(color: GravityColors.gray200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            GravityRadii.button,
                          ),
                        ),
                      ),
                      child: const Text(
                        "Explore demo studio",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _SupportFooter(),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandingHeader extends StatelessWidget {
  const _BrandingHeader({required this.tenantName});

  final String tenantName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: GravityColors.primary50,
            borderRadius: BorderRadius.circular(GravityRadii.logo),
          ),
          child: const Icon(
            Icons.arrow_upward_rounded,
            size: 36,
            color: GravityColors.primary600,
          ),
        ),
        const SizedBox(height: GravitySpacing.md),
        const Text(
          "Welcome back",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: GravityColors.gray900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Sign in to your $tenantName account",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: GravityColors.gray600,
            height: 1.2,
          ),
        ),
      ],
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
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: GravityColors.gray900,
          ),
        ),
        const SizedBox(height: GravitySpacing.sm),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            autofillHints: autofillHints,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: GravityColors.gray900,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
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
                borderSide: const BorderSide(color: GravityColors.gray200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GravityRadii.md),
                borderSide: const BorderSide(color: GravityColors.gray200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GravityRadii.md),
                borderSide: const BorderSide(
                  color: GravityColors.primary600,
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
        const Text(
          "Need help? Contact your gym management",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: GravityColors.gray400,
          ),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Email support@ironpeakfitness.com"),
              ),
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            "support@ironpeakfitness.com",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: GravityColors.gray600,
              decoration: TextDecoration.underline,
              decorationColor: GravityColors.gray600,
            ),
          ),
        ),
      ],
    );
  }
}
