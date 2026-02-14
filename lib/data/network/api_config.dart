import 'package:flutter/foundation.dart';

/// API Configuration
/// Base URL configuration for the system
class APIConfig {
  // Production and Debug hosts
  // Updated with the correct host from the plan
  static const String _prodHost = "survey-api.system2030.com";
  static const String _debugHost = "survey-api.system2030.com";

  /// Get the current host based on build mode
  static String get host => kDebugMode ? _debugHost : _prodHost;

  /// Base URL for the API
  static String get baseUrl => "https://$host";

  /// Full API endpoint URL
  static String get appAPI => "$baseUrl";

  /// Get full image URL from a relative path
  static String getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('https://')) {
      return imagePath;
    }
    return "$baseUrl$imagePath";
  }

  /// Base URL for the survey frontend (public survey links open in browser).
  /// Used to build short-lived links with locale and path: base/survey/{shortCode}.
  static const String surveyFrontendBaseUrl =
      'https://survey-frontend.system2030.com/ar';
}
