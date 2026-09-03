import "dart:convert";

import "package:dio/dio.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Disk-backed cache of successful `GET` envelopes, replayed when the network
/// is unreachable so members can still see their schedule and bookings.
///
/// Only whole response bodies are stored, keyed by method + path + query, which
/// keeps the cache oblivious to model shapes.
class ResponseCache {
  ResponseCache(this._prefs);

  static const _prefix = "api_cache:";
  static const _maxAge = Duration(days: 7);

  final SharedPreferences _prefs;

  static String keyFor(RequestOptions options) {
    final query =
        options.queryParameters.entries
            .map((entry) => "${entry.key}=${entry.value}")
            .toList()
          ..sort();
    return "$_prefix${options.method}:${options.path}?${query.join("&")}";
  }

  Future<void> write(RequestOptions options, Object? body) async {
    if (body == null) return;
    try {
      await _prefs.setString(
        keyFor(options),
        jsonEncode({
          "savedAt": DateTime.now().toUtc().toIso8601String(),
          "body": body,
        }),
      );
    } catch (_) {
      // A cache write must never fail a request.
    }
  }

  CachedResponse? read(RequestOptions options) {
    final raw = _prefs.getString(keyFor(options));
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt = DateTime.parse(decoded["savedAt"] as String);
      if (DateTime.now().toUtc().difference(savedAt) > _maxAge) {
        _prefs.remove(keyFor(options));
        return null;
      }
      return CachedResponse(body: decoded["body"], savedAt: savedAt);
    } catch (_) {
      _prefs.remove(keyFor(options));
      return null;
    }
  }

  /// Called on sign-out so a shared device never leaks the previous member's data.
  Future<void> clear() async {
    for (final key in _prefs.getKeys().where((k) => k.startsWith(_prefix))) {
      await _prefs.remove(key);
    }
  }
}

class CachedResponse {
  const CachedResponse({required this.body, required this.savedAt});

  final Object? body;
  final DateTime savedAt;
}

/// Marks responses that were replayed from disk rather than fetched.
const cachedResponseHeader = "x-gravity-cached-at";

class OfflineCacheInterceptor extends Interceptor {
  OfflineCacheInterceptor(this._cache);

  final ResponseCache _cache;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (response.requestOptions.method == "GET" && response.statusCode == 200) {
      _cache.write(response.requestOptions, response.data);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final isTransportFailure = err.response == null;
    if (err.requestOptions.method != "GET" || !isTransportFailure) {
      handler.next(err);
      return;
    }

    final cached = _cache.read(err.requestOptions);
    if (cached == null) {
      handler.next(err);
      return;
    }

    handler.resolve(
      Response<dynamic>(
        requestOptions: err.requestOptions,
        data: cached.body,
        statusCode: 200,
        headers: Headers.fromMap({
          cachedResponseHeader: [cached.savedAt.toIso8601String()],
        }),
      ),
    );
  }
}
