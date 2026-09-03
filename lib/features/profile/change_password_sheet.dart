import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/api/api_exception.dart";
import "../../core/providers/app_providers.dart";
import "../../core/theme/gravity_palette.dart";
import "../../core/widgets/gravity_button.dart";
import "../../core/widgets/gravity_input.dart";

Future<void> showChangePasswordSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.palette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const ChangePasswordSheet(),
  );
}

class ChangePasswordSheet extends ConsumerStatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  ConsumerState<ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<ChangePasswordSheet> {
  final _currentController = TextEditingController();
  final _nextController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _nextController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentController.text;
    final next = _nextController.text;
    final confirm = _confirmController.text;

    if (current.isEmpty || next.isEmpty) {
      setState(() => _error = "Enter your current and new password.");
      return;
    }
    if (next.length < 8) {
      setState(() => _error = "New password must be at least 8 characters.");
      return;
    }
    if (next != confirm) {
      setState(() => _error = "New passwords don’t match.");
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref
          .read(authSessionProvider.notifier)
          .changePassword(currentPassword: current, newPassword: next);
      if (!mounted) return;
      Navigator.pop(context);
      await ref.read(authSessionProvider.notifier).logout();
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } catch (_) {
      setState(() => _error = "Couldn’t update password.");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
            "Change password",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: context.palette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You’ll be signed out after the password is updated.",
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: context.palette.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          GravityInput(
            label: "Current password",
            controller: _currentController,
            obscureText: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.password],
          ),
          const SizedBox(height: 12),
          GravityInput(
            label: "New password",
            controller: _nextController,
            obscureText: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
          ),
          const SizedBox(height: 12),
          GravityInput(
            label: "Confirm new password",
            controller: _confirmController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: context.palette.danger)),
          ],
          const SizedBox(height: 20),
          GravityButton(
            label: "Update password",
            isLoading: _saving,
            onPressed: _saving ? null : _submit,
          ),
        ],
      ),
    );
  }
}
