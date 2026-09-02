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
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _tenantDisplayName() {
    return _defaultTenant
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
          .read(authRepositoryProvider)
          .login(
            LoginRequest(
              tenantSlug: _defaultTenant,
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
      ref.invalidate(authSessionProvider);
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } catch (_) {
      setState(() => _error = "Unable to sign in. Check your credentials.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
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
                  const SizedBox(height: 32),
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
          onPressed: () {},
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
