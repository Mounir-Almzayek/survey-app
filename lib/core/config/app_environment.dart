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

  /// Tile URL template for the map picker. Defaults to OpenStreetMap.
  static String get mapTileUrl {
    if (!dotenv.isInitialized) return _defaultMapTileUrl;
    final v = dotenv.env['MAP_TILE_URL']?.trim();
    return (v == null || v.isEmpty) ? _defaultMapTileUrl : v;
  }

  /// Default map centre (Riyadh) when no value is known.
  static ({double latitude, double longitude}) get mapDefaultLatLng {
    double parseOr(String? s, double fallback) =>
        s == null ? fallback : double.tryParse(s.trim()) ?? fallback;

    if (!dotenv.isInitialized) {
      return (latitude: _defaultMapLat, longitude: _defaultMapLng);
    }
    return (
      latitude: parseOr(dotenv.env['MAP_DEFAULT_LAT'], _defaultMapLat),
      longitude: parseOr(dotenv.env['MAP_DEFAULT_LNG'], _defaultMapLng),
    );
  }

  static const String _defaultMapTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const double _defaultMapLat = 24.72169;
  static const double _defaultMapLng = 46.75702;
}
