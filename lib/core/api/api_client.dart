import "package:dio/dio.dart";

import "../auth/auth_session.dart";
import "../auth/auth_storage.dart";
import "../config/app_config.dart";
import "api_exception.dart";

class ApiEnvelope<T> {
  ApiEnvelope({required this.data, this.error});

  final T? data;
  final ApiErrorBody? error;

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiEnvelope(
      data: json["data"] == null ? null : fromJsonT(json["data"]),
      error: json["error"] == null
          ? null
          : ApiErrorBody.fromJson(json["error"] as Map<String, dynamic>),
    );
  }
}

class ApiErrorBody {
  ApiErrorBody({required this.code, required this.message});

  final String code;
  final String message;

  factory ApiErrorBody.fromJson(Map<String, dynamic> json) {
    return ApiErrorBody(
      code: json["code"] as String? ?? "REQUEST_FAILED",
      message: json["message"] as String? ?? "Request failed",
    );
  }
}

class ApiClient {
  ApiClient({
    required AppConfig config,
    required this._authStorage,
    Dio? dio,
  })  : _config = config,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: config.apiBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {"Content-Type": "application/json"},
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = await _authStorage.readSession();
          if (session?.accessToken != null) {
            options.headers["Authorization"] = "Bearer ${session!.accessToken}";
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _tryRefreshToken();
            if (refreshed != null) {
              final request = error.requestOptions;
              request.headers["Authorization"] = "Bearer ${refreshed.accessToken}";
              try {
                final response = await _dio.fetch(request);
                handler.resolve(response);
                return;
              } catch (retryError) {
                if (retryError is DioException) {
                  handler.next(retryError);
                  return;
                }
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final AppConfig _config;
  final AuthStorage _authStorage;
  final Dio _dio;

  Future<AuthSession?> _tryRefreshToken() async {
    final session = await _authStorage.readSession();
    if (session?.refreshToken == null) return null;

    try {
      final response = await Dio(
        BaseOptions(baseUrl: _config.apiBaseUrl),
      ).post(
        "/api/v1/auth/refresh",
        data: {"refreshToken": session!.refreshToken},
      );
      final envelope = ApiEnvelope<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );
      final data = envelope.data;
      if (data == null) return null;

      final nextSession = AuthSession(
        accessToken: data["accessToken"] as String,
        refreshToken: data["refreshToken"] as String,
        expiresIn: data["expiresIn"] as int,
        user: AuthUser.fromJson(data["user"] as Map<String, dynamic>),
        expiresAt: DateTime.now().add(
          Duration(seconds: data["expiresIn"] as int),
        ),
      );
      await _authStorage.saveSession(nextSession);
      return nextSession;
    } catch (_) {
      await _authStorage.clearSession();
      return null;
    }
  }

  Future<T> get<T>(
    String path, {
    required T Function(Object? json) fromJson,
  }) {
    return _request("GET", path, fromJson: fromJson);
  }

  Future<T> put<T>(
    String path, {
    Object? data,
    required T Function(Object? json) fromJson,
  }) {
    return _request("PUT", path, data: data, fromJson: fromJson);
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    required T Function(Object? json) fromJson,
  }) {
    return _request("POST", path, data: data, fromJson: fromJson);
  }

  Future<T> upload<T>(
    String path, {
    required String fieldName,
    required String filePath,
    required T Function(Object? json) fromJson,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
    });

    try {
      final response = await _dio.post(path, data: formData);
      return _parseResponse(response, fromJson);
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  Future<T> _request<T>(
    String method,
    String path, {
    Object? data,
    required T Function(Object? json) fromJson,
  }) async {
    try {
      final response = await _dio.request(
        path,
        data: data,
        options: Options(method: method),
      );
      return _parseResponse(response, fromJson);
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  T _parseResponse<T>(
    Response<dynamic> response,
    T Function(Object? json) fromJson,
  ) {
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw ApiException(message: "Invalid response", code: "INVALID_RESPONSE");
    }

    final envelope = ApiEnvelope<T>.fromJson(body, fromJson);
    if (envelope.error != null) {
      throw ApiException(
        message: envelope.error!.message,
        code: envelope.error!.code,
        statusCode: response.statusCode,
      );
    }
    if (envelope.data == null) {
      throw ApiException(message: "Empty response", code: "EMPTY_RESPONSE");
    }
    return envelope.data as T;
  }

  ApiException _mapDioError(DioException error) {
    final response = error.response;
    if (response?.data is Map<String, dynamic>) {
      final envelope = ApiEnvelope<dynamic>.fromJson(
        response!.data as Map<String, dynamic>,
        (json) => json,
      );
      if (envelope.error != null) {
        return ApiException(
          message: envelope.error!.message,
          code: envelope.error!.code,
          statusCode: response.statusCode,
        );
      }
    }
    return ApiException(
      message: error.message ?? "Network request failed",
      code: "NETWORK_ERROR",
      statusCode: response?.statusCode,
    );
  }
}
