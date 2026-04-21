import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Selects which `.env` keys (`*_DEV`, `*_STAGING`, `*_PROD`) are used.
///
/// Resolution order:
/// 1. `--flavor` passed to `flutter run/build` (Flutter auto-propagates it as
///    a compile-time `FLUTTER_APP_FLAVOR` dart-define since Flutter 3.19+).
/// 2. `APP_ENV` from `.env` (legacy fallback for non-flavored builds).
/// 3. `dev` as a last-resort default.
class AppEnvironment {
  AppEnvironment._();

  /// Flavor baked into the build at compile time by `flutter --flavor <name>`.
  /// Empty string when the build has no flavor.
  static const String _flavorFromBuild =
      String.fromEnvironment('FLUTTER_APP_FLAVOR');

  static String _rawMode() {
    if (_flavorFromBuild.isNotEmpty) {
      return _flavorFromBuild.toLowerCase();
    }
    if (!dotenv.isInitialized) {
      throw StateError('dotenv is not initialized; call dotenv.load() in main().');
    }
    final envValue = dotenv.env['APP_ENV']?.trim();
    if (envValue != null && envValue.isNotEmpty) {
      return envValue.toLowerCase();
    }
    return 'dev';
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
