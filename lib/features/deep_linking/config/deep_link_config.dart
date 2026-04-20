class DeepLinkConfig {
  DeepLinkConfig._();

  /// Active host for App Links / Universal Links.
  /// Injected at build time per flavor via --dart-define=DEEP_LINK_HOST=...
  static const String expectedHost = String.fromEnvironment(
    'DEEP_LINK_HOST',
    defaultValue: 'survey-frontend.system2030.com',
  );

  static const List<String> supportedLocales = ['ar', 'en'];

  static const String registerDevicePath = '/register-device';
  static const String surveyPathPrefix = '/survey';
}
