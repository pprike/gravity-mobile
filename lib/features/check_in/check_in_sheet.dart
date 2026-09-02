import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:qr_flutter/qr_flutter.dart";

import "../../core/providers/app_providers.dart";
import "../../core/theme/design_tokens.dart";
import "../../core/widgets/gravity_button.dart";
import "check_in_repository.dart";
import "models/check_in_qr.dart";

Future<void> showCheckInSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
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
      ).getCheckInQr();
      if (!mounted) return;
      setState(() {
        _qr = qr;
        _loading = false;
      });
      _scheduleRefresh(qr);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
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
              color: GravityColors.gray200,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: GravitySpacing.lg),
          const Text(
            "Check in",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: GravityColors.gray900,
            ),
          ),
          const SizedBox(height: GravitySpacing.sm),
          const Text(
            "Show this code at the front desk. It refreshes automatically so it can’t be reused.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: GravityColors.gray600,
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
              style: const TextStyle(color: GravityColors.danger600),
            ),
            const SizedBox(height: GravitySpacing.md),
            GravityButton(label: "Try again", onPressed: _load),
          ] else if (_qr != null)
            Container(
              padding: const EdgeInsets.all(GravitySpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(GravityRadii.xl),
                border: Border.all(color: GravityColors.gray200),
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: _qr!.qrPayload,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: GravitySpacing.sm),
                  Text(
                    "Expires ${_formatExpiry(_qr!.expiresAt)}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: GravityColors.gray500,
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

  String _formatExpiry(DateTime expiresAt) {
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.inSeconds <= 0) return "soon";
    if (remaining.inMinutes < 1) return "in ${remaining.inSeconds}s";
    return "in ${remaining.inMinutes}m";
  }
}
