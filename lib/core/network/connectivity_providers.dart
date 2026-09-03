import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

bool _isOnline(List<ConnectivityResult> results) {
  return results.any((result) => result != ConnectivityResult.none);
}

/// Whether the device currently has a network interface.
///
/// This reports link state, not reachability — the studio API can still be
/// unreachable while this is `true`, which is why request errors are surfaced
/// separately.
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = ref.watch(connectivityProvider);
  yield _isOnline(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_isOnline);
});
