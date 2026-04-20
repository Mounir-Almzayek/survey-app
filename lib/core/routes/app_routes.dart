/// App Routes
/// Centralized route path definitions
class Routes {
  // Auth routes
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String forgotPasswordPath = '/forgot-password';
  static const String verifyEmailPath = '/verify-email';

  // Main routes
  static const String homePath = '/home';
  static const String mainScreenPath = '/main';
  static const String splashPath = '/splash';
  static const String welcomePath = '/welcome';

  // Feature routes
  static const String profilePath = '/profile';
  static const String notificationsPath = '/notifications';
  static const String qrScannerPath = '/qr-scanner';
  static const String deviceRegistrationPath = '/device-registration';
  static const String custodyTransferPath = '/custody-transfer';
  static const String custodyVerificationPath = '/custody-verification';
  static const String surveyAnsweringPath = '/survey-answering';
  static const String surveyDeepLinkPath = '/survey-deep-link';
  static const String completedResponsesPath = '/completed-responses';
  static const String completedResponseViewPath = '/completed-response-view';
  static const String publicLinkAnsweringPath = '/public-link-answering';

  // Route names
  static const String notifications = 'notifications';
}
