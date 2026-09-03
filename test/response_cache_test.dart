import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:gravity_mobile/core/api/response_cache.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ResponseCache cache;
  late Dio dio;
  late int upstreamCalls;
  late bool upstreamOffline;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cache = ResponseCache(await SharedPreferences.getInstance());

    upstreamCalls = 0;
    upstreamOffline = false;

    dio = Dio(BaseOptions(baseUrl: "https://studio.test"));
    dio.interceptors.add(OfflineCacheInterceptor(cache));
    dio.httpClientAdapter = _FakeAdapter(
      onRequest: () {
        upstreamCalls++;
        if (upstreamOffline) throw const _Offline();
      },
    );
  });

  Future<Response<dynamic>> fetchSchedule() {
    return dio.get<dynamic>(
      "/api/v1/schedule",
      queryParameters: {"day": "2026-09-02"},
    );
  }

  test(
    "replays the last good response when the network is unreachable",
    () async {
      final live = await fetchSchedule();
      expect(live.data, {"data": "ok"});

      upstreamOffline = true;
      final cached = await fetchSchedule();

      expect(cached.data, {"data": "ok"});
      expect(cached.statusCode, 200);
      expect(
        cached.headers.value(cachedResponseHeader),
        isNotNull,
        reason: "callers need to know the payload came from disk",
      );
      expect(upstreamCalls, 2);
    },
  );

  test("still fails when there is nothing cached for the request", () async {
    upstreamOffline = true;

    await expectLater(fetchSchedule(), throwsA(isA<DioException>()));
  });

  test("keys entries per query, so one day cannot mask another", () async {
    await fetchSchedule();
    upstreamOffline = true;

    await expectLater(
      dio.get<dynamic>(
        "/api/v1/schedule",
        queryParameters: {"day": "2026-09-03"},
      ),
      throwsA(isA<DioException>()),
    );
  });

  test("clearing drops cached member data on sign-out", () async {
    await fetchSchedule();
    await cache.clear();
    upstreamOffline = true;

    await expectLater(fetchSchedule(), throwsA(isA<DioException>()));
  });
}

class _Offline implements Exception {
  const _Offline();
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({required this.onRequest});

  final void Function() onRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    try {
      onRequest();
    } on _Offline {
      throw DioException.connectionError(
        requestOptions: options,
        reason: "no route to host",
      );
    }
    return ResponseBody.fromString(
      '{"data":"ok"}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
