import 'package:dio/dio.dart';
import 'package:flutter/scheduler.dart';
import '../routes/app_pages.dart';
import '../routes/app_routes.dart';
import 'session_invalidation_policy.dart';

typedef SessionInvalidationAfterClearedCallback = void Function();

/// Central entry for handling revoked / invalid auth from HTTP responses.
/// Registered once at app startup with a [SessionInvalidationPolicy] implementation.
final class SessionInvalidationCoordinator {
  SessionInvalidationCoordinator._();

  static final SessionInvalidationCoordinator instance =
      SessionInvalidationCoordinator._();

  SessionInvalidationPolicy? _policy;
  SessionInvalidationAfterClearedCallback? _afterCleared;
  Future<void>? _inFlight;

  /// Call from [main] or the root widget after DI is ready.
  void configure({
    required SessionInvalidationPolicy policy,
    SessionInvalidationAfterClearedCallback? afterCleared,
  }) {
    _policy = policy;
    _afterCleared = afterCleared;
  }

  /// Invoked by the Dio layer when an error response indicates auth is no longer valid.
  Future<void> handleIfNeeded(DioException error) async {
    if (!_isUnauthorizedOrForbidden(error)) return;
    if (!_hadBearerToken(error.requestOptions)) return;

    if (_inFlight != null) {
      await _inFlight;
      return;
    }

    _inFlight = _invalidate();
    try {
      await _inFlight;
    } finally {
      _inFlight = null;
    }
  }

  bool _isUnauthorizedOrForbidden(DioException error) {
    final code = error.response?.statusCode;
    return code == 401 || code == 403;
  }

  bool _hadBearerToken(RequestOptions options) {
    final raw = _authorizationHeaderValue(options);
    if (raw == null) return false;
    final trimmed = raw.trim();
    if (!trimmed.toLowerCase().startsWith('bearer ')) return false;
    final token = trimmed.substring(7).trim();
    return token.isNotEmpty;
  }

  String? _authorizationHeaderValue(RequestOptions options) {
    for (final e in options.headers.entries) {
      if (e.key.toLowerCase() != 'authorization') continue;
      final v = e.value;
      if (v is String) return v;
      if (v is List && v.isNotEmpty) return v.first.toString();
    }
    return null;
  }

  Future<void> _invalidate() async {
    final policy = _policy;
    if (policy == null) return;

    await policy.clearAuthAndUserData();

    final after = _afterCleared;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      after?.call();
      appPages.go(Routes.loginPath);
    });
  }
}
