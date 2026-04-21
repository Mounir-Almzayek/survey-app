import '../../../data/network/api_config.dart';

class DeepLinkConfig {
  DeepLinkConfig._();

  /// Active host for App Links / Universal Links.
  ///
  /// Derived at runtime from `APIConfig.surveyFrontendBaseUrl`, which reads
  /// `SURVEY_FRONTEND_BASE_URL_<env>` from `.env`. The `<env>` suffix is
  /// chosen by `AppEnvironment` based on the Flutter flavor the build was
  /// produced with (FLUTTER_APP_FLAVOR). No hardcoded default.
  static String get expectedHost {
    final raw = APIConfig.surveyFrontendBaseUrl;
    final host = Uri.tryParse(raw)?.host ?? '';
    if (host.isNotEmpty) return host;
    // Defensive fallback: strip scheme and anything after the first '/'.
    return raw
        .replaceFirst(RegExp(r'^https?://'), '')
        .split('/')
        .first;
  }

  /// Legacy path used by earlier backend builds. Kept for backward compatibility.
  static const String registerDevicePath = '/register-device';

  /// Canonical path used by the current survey frontend.
  static const String deviceRegistrationPath = '/device-registration';

  static const String surveyPathPrefix = '/survey';
}
