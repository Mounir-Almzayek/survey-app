import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/config/app_environment.dart';

/// API Configuration — URLs and locale come only from `.env` (no hardcoded fallbacks).
class APIConfig {
  static String _requireEnv(String key) {
    if (!dotenv.isInitialized) {
      throw StateError('dotenv is not initialized; call dotenv.load() in main().');
    }
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty) {
      throw StateError('Missing or empty "$key" in .env for env ${AppEnvironment.envKeySuffix}.');
    }
    return value.trim();
  }

  /// Get the current API host based on `.env` and [AppEnvironment.envKeySuffix].
  static String get host {
    final envUrl = _requireEnv('API_BASE_URL_${AppEnvironment.envKeySuffix}');
    return envUrl.replaceAll('https://', '');
  }

  /// Survey frontend base URL from `.env`.
  static String get surveyFrontendBaseUrl {
    return _requireEnv('SURVEY_FRONTEND_BASE_URL_${AppEnvironment.envKeySuffix}');
  }

  /// Default locale for survey links from `.env`.
  static String get defaultLocale {
    return _requireEnv('SURVEY_DEFAULT_LOCALE');
  }

  /// Base URL for the API
  static String get baseUrl => "https://$host";

  /// Full API endpoint URL
  static String get appAPI => baseUrl;

  /// Get full image URL from a relative path
  static String getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('https://')) {
      return imagePath;
    }
    return "$baseUrl$imagePath";
  }

  /// Build public survey URL with short code
  static String buildPublicSurveyUrl(String shortCode, {String? locale}) {
    final loc = locale ?? defaultLocale;
    return "$surveyFrontendBaseUrl/$loc/survey/$shortCode";
  }

  /// Build short-lived survey URL with location parameters
  static String buildShortLivedSurveyUrl(
    String shortCode,
    double latitude,
    double longitude, {
    String? locale,
  }) {
    final loc = locale ?? defaultLocale;
    return "$surveyFrontendBaseUrl/$loc/survey/$shortCode?lat=$latitude&lng=$longitude";
  }
}
