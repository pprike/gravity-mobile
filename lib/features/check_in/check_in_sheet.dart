import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:qr_flutter/qr_flutter.dart";

import "../../core/api/error_messages.dart";
import "../../core/providers/app_providers.dart";
import "../../core/theme/design_tokens.dart";
import "../../core/theme/gravity_palette.dart";
import "../../core/widgets/gravity_button.dart";
import "../../core/widgets/gravity_feedback.dart";
import "check_in_repository.dart";
import "models/check_in_qr.dart";

Future<void> showCheckInSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.palette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const CheckInSheet(),
  );
}

class CheckInSheet extends ConsumerStatefulWidget {
  const CheckInSheet({super.key});

  @override
  ConsumerState<CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends ConsumerState<CheckInSheet> {
  CheckInQr? _qr;
  String? _error;
  bool _loading = true;
  Timer? _refreshTimer;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _qr != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final qr = await CheckInRepository(
        ref.read(apiClientProvider),
        demoCatalog: ref.read(demoCatalogProvider),
        demoMode: ref.read(isDemoModeProvider),
      ).getCheckInQr();
      if (!mounted) return;
      setState(() {
        _qr = qr;
        _loading = false;
      });
      GravityFeedback.success();
      _scheduleRefresh(qr);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = friendlyErrorMessage(
          error,
          fallback: "Couldn’t create your check-in code. Please try again.",
        );
        _loading = false;
      });
    }
  }

  void _scheduleRefresh(CheckInQr qr) {
    _refreshTimer?.cancel();
    final untilRefresh =
        qr.expiresAt.difference(DateTime.now()) - const Duration(seconds: 8);
    final delay = untilRefresh.isNegative
        ? const Duration(seconds: 2)
        : untilRefresh;
    _refreshTimer = Timer(delay, _load);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        GravitySpacing.lg,
        GravitySpacing.md,
        GravitySpacing.lg,
        MediaQuery.paddingOf(context).bottom + GravitySpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.palette.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: GravitySpacing.lg),
          Text(
            "Check in",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.palette.textPrimary,
            ),
          ),
          const SizedBox(height: GravitySpacing.sm),
          Text(
            "Show this code at the front desk. It refreshes automatically so it can’t be reused.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: context.palette.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: GravitySpacing.lg),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: CircularProgressIndicator(),
            )
          else if (_error != null) ...[
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.palette.danger),
            ),
            const SizedBox(height: GravitySpacing.md),
            GravityButton(label: "Try again", onPressed: _load),
          ] else if (_qr != null)
            Container(
              padding: const EdgeInsets.all(GravitySpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(GravityRadii.xl),
                border: Border.all(color: context.palette.border),
              ),
              child: Column(
                children: [
                  Semantics(
                    label:
                        "Your check-in QR code. Show this at the front desk.",
                    image: true,
                    child: ExcludeSemantics(
                      child: QrImageView(
                        data: _qr!.qrPayload,
                        size: 220,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: GravitySpacing.sm),
                  // The QR plate stays white in both themes so scanners keep
                  // working, so this caption can't follow the palette.
                  Text(
                    _expiryLabel(_qr!.expiresAt),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: GravityColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: GravitySpacing.lg),
        ],
      ),
    );
  }

  String _expiryLabel(DateTime expiresAt) {
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.inSeconds <= 0) return "Refreshing code…";
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return "Expires in ${minutes > 0 ? "$minutes:${seconds.toString().padLeft(2, "0")}" : "${seconds}s"}";
  }
}
