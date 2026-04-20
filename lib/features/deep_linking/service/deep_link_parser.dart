import '../config/deep_link_config.dart';
import '../models/deep_link.dart';

class DeepLinkParser {
  DeepLinkParser._();

  static DeepLink parse(Uri uri) {
    if (uri.scheme != 'https') return UnknownLink(uri);
    if (uri.host != DeepLinkConfig.expectedHost) return UnknownLink(uri);

    final segments = _normalize(uri.pathSegments);
    if (segments.isEmpty) return UnknownLink(uri);

    final afterLocale = _stripLocale(segments);
    if (afterLocale.isEmpty) return UnknownLink(uri);

    if (afterLocale.length == 1 && afterLocale.first == 'register-device') {
      final raw = uri.queryParameters['token'];
      final token = raw?.trim() ?? '';
      if (token.isEmpty) return UnknownLink(uri);
      return RegisterDeviceLink(token);
    }

    if (afterLocale.length == 2 && afterLocale.first == 'survey') {
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

  static List<String> _stripLocale(List<String> segments) {
    if (segments.isEmpty) return segments;
    final first = segments.first;
    if (DeepLinkConfig.supportedLocales.contains(first)) {
      return segments.sublist(1);
    }
    return segments;
  }
}
