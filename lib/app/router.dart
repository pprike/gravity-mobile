import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../core/providers/app_providers.dart";
import "../features/auth/login_screen.dart";
import "../features/home/home_shell.dart";

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authSessionProvider);

  return GoRouter(
    initialLocation: "/login",
    refreshListenable: _AuthRefreshListenable(ref),
    redirect: (context, state) {
      if (authState.isLoading) return null;

      final session = authState.valueOrNull;
      final loggingIn = state.matchedLocation == "/login";

      if (session == null) {
        return loggingIn ? null : "/login";
      }
      if (loggingIn) return "/";
      return null;
    },
    routes: [
      GoRoute(path: "/login", builder: (context, state) => const LoginScreen()),
      GoRoute(path: "/", builder: (context, state) => const HomeShell()),
    ],
  );
});

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._ref) {
    _subscription = _ref.listen<AsyncValue<dynamic>>(
      authSessionProvider,
      (_, _) => notifyListeners(),
    );
  }

  final Ref _ref;
  late final ProviderSubscription<AsyncValue<dynamic>> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
