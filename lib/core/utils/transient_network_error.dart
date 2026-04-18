import 'app_exception.dart';

/// True for timeouts / no route / server errors worth retrying — not validation (4xx) issues.
bool isTransientNetworkFailure(Object error) {
  if (error is! AppException) return false;
  final code = error.errorCode.toLowerCase();
  if (code == 'request-cancelled') return false;
  if (code == 'timeout' ||
      code == 'no-internet' ||
      code == 'connection-error') {
    return true;
  }
  final sc = error.statusCode;
  return sc == 408 || sc == 503 || (sc >= 500 && sc < 600);
}
