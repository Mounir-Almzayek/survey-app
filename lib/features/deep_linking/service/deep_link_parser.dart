import '../config/deep_link_config.dart';
import '../models/deep_link.dart';

class DeepLinkParser {
  DeepLinkParser._();

  static const Set<String> _endpoints = {
    'register-device',
    'device-registration',
    'survey',
  };

  static DeepLink parse(Uri uri) {
    if (uri.scheme != 'https') return UnknownLink(uri);
    if (uri.host != DeepLinkConfig.expectedHost) return UnknownLink(uri);

    final segments = _normalize(uri.pathSegments);
    if (segments.isEmpty) return UnknownLink(uri);

    final afterLocale = _stripLocale(segments);
    if (afterLocale.isEmpty) return UnknownLink(uri);

    final endpoint = afterLocale.first;

    if (endpoint == 'register-device' || endpoint == 'device-registration') {
      if (afterLocale.length != 1) return UnknownLink(uri);
      final raw = uri.queryParameters['token'];
      final token = raw?.trim() ?? '';
      if (token.isEmpty) return UnknownLink(uri);
      return RegisterDeviceLink(token);
    }

    if (endpoint == 'survey') {
      if (afterLocale.length != 2) return UnknownLink(uri);
      final code = afterLocale[1].trim();
      if (code.isEmpty) return UnknownLink(uri);
      return SurveyLink(code);
    }

    return UnknownLink(uri);
  }

  static List<String> _normalize(List<String> segments) {
    return segments
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Treats any first segment that is NOT a known endpoint marker as a locale
  /// and strips it. Any locale value delivered by the URL is accepted; the
  /// parser never hardcodes the supported locales list.
  static List<String> _stripLocale(List<String> segments) {
    if (segments.isEmpty) return segments;
    if (_endpoints.contains(segments.first)) return segments;
    return segments.sublist(1);
  }
}
