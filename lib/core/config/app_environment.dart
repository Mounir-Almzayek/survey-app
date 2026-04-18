import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Selects which `.env` keys (`*_DEV`, `*_STAGING`, `*_PROD`) are used.
///
/// Set the active mode in `.env` with `APP_ENV` (see that file).
class AppEnvironment {
  AppEnvironment._();

  static String _rawMode() {
    if (!dotenv.isInitialized) {
      throw StateError('dotenv is not initialized; call dotenv.load() in main().');
    }
    return (dotenv.env['APP_ENV']?.trim() ?? 'dev').toLowerCase();
  }

  /// `true` when [envKeySuffix] targets dev (RS4IT small logo, etc.).
  static bool get isDevBranding => _rawMode() == 'dev';

  /// Suffix for keys like `API_BASE_URL_DEV`, `API_BASE_URL_STAGING`, `API_BASE_URL_PROD`.
  static String get envKeySuffix {
    switch (_rawMode()) {
      case 'prod':
      case 'production':
        return 'PROD';
      case 'staging':
      case 'stage':
        return 'STAGING';
      case 'dev':
      case 'development':
      default:
        return 'DEV';
    }
  }
}
