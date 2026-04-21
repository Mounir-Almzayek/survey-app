import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/email_verification_page.dart';
import '../../features/welcome/presentation/welcome_page.dart';
import '../../features/main_screen/presentation/main_page.dart';
import '../../features/device_registration/presentation/device_registration_page.dart';
import '../../features/qr_scanner/presentation/qr_scanner_page.dart';
import '../../features/assignment/presentation/pages/survey_answering_page.dart';
import '../../features/assignment/presentation/pages/completed_responses_page.dart';
import '../../features/assignment/presentation/pages/completed_response_view_page.dart';
import '../../features/assignment/presentation/pages/survey_deep_link_page.dart';
import '../../features/deep_linking/models/deep_link.dart';
import '../../features/deep_linking/models/device_registration_args.dart';
import '../../features/deep_linking/models/survey_deep_link_args.dart';
import '../../features/deep_linking/service/deep_link_parser.dart';
import '../../features/custody/presentation/custody_transfer_page.dart';
import '../../features/custody/presentation/custody_verification_page.dart';
import '../../features/public_links/models/public_link_answering_args.dart';
import '../../features/public_links/presentation/public_link_answering_page.dart';
import '../../core/models/survey/survey_model.dart';
import 'app_routes.dart';

/// App Pages
/// Route configuration using GoRouter
class Pages {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

final appPages = GoRouter(
  navigatorKey: Pages.navigatorKey,
  initialLocation: Routes.splashPath,
  redirect: (context, state) {
    // Android App Links / iOS Universal Links are delivered by the framework
    // as absolute URLs (e.g. "https://host/ar/device-registration?token=...").
    // GoRouter can't match those against its internal paths and throws
    // "no routes for location". Parse the URL with DeepLinkParser and rewrite
    // to the matching internal path; internal navigations (no scheme) pass
    // through untouched.
    final uri = state.uri;
    if (!uri.hasScheme) return null;

    final link = DeepLinkParser.parse(uri);
    switch (link) {
      case RegisterDeviceLink(:final token):
        return Uri(
          path: Routes.deviceRegistrationPath,
          queryParameters: {
            'token': token,
            'fromDeepLink': 'true',
          },
        ).toString();
      case SurveyLink(:final shortCode):
        return Uri(
          path: Routes.surveyDeepLinkPath,
          queryParameters: {'shortCode': shortCode},
        ).toString();
      case UnknownLink():
        return Routes.splashPath;
    }
  },
  routes: [
    GoRoute(
      path: Routes.splashPath,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: Routes.welcomePath,
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: Routes.loginPath,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: Routes.forgotPasswordPath,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: Routes.verifyEmailPath,
      builder: (context, state) => const EmailVerificationPage(),
    ),
    GoRoute(
      path: Routes.mainScreenPath,
      builder: (context, state) => const MainPage(),
    ),
    GoRoute(
      path: Routes.notificationsPath,
      name: Routes.notifications,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Notifications')),
          body: const Center(child: Text('Notifications Page')),
        );
      },
    ),
    GoRoute(
      path: Routes.deviceRegistrationPath,
      builder: (context, state) {
        final args = state.extra;
        if (args is DeviceRegistrationArgs) {
          return DeviceRegistrationPage(
            token: args.token,
            fromDeepLink: args.fromDeepLink,
          );
        }
        final token = state.uri.queryParameters['token'];
        final fromDeepLink =
            state.uri.queryParameters['fromDeepLink'] == 'true';
        return DeviceRegistrationPage(
          token: token,
          fromDeepLink: fromDeepLink,
        );
      },
    ),
    GoRoute(
      path: Routes.custodyTransferPath,
      builder: (context, state) => const CustodyTransferPage(),
    ),
    GoRoute(
      path: Routes.custodyVerificationPath,
      builder: (context, state) {
        final custodyId = int.parse(state.uri.queryParameters['custodyId']!);
        return CustodyVerificationPage(custodyId: custodyId);
      },
    ),
    GoRoute(
      path: Routes.qrScannerPath,
      builder: (context, state) {
        final returnCodeOnly =
            state.uri.queryParameters['returnCodeOnly'] == 'true';
        return QrScannerPage(returnCodeOnly: returnCodeOnly);
      },
    ),
    GoRoute(
      path: Routes.surveyDeepLinkPath,
      builder: (context, state) {
        final args = state.extra;
        if (args is SurveyDeepLinkArgs) {
          return SurveyDeepLinkPage(shortCode: args.shortCode);
        }
        final shortCode = state.uri.queryParameters['shortCode'] ?? '';
        return SurveyDeepLinkPage(shortCode: shortCode);
      },
    ),
    GoRoute(
      path: Routes.surveyAnsweringPath,
      builder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        final survey = extra['survey'] as Survey;
        final responseId = extra['responseId'] as int?;
        return SurveyAnsweringPage(survey: survey, responseId: responseId);
      },
    ),
    GoRoute(
      path: Routes.completedResponsesPath,
      builder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        final surveyId = extra['surveyId'] as int;
        return CompletedResponsesPage(surveyId: surveyId);
      },
    ),
    GoRoute(
      path: Routes.completedResponseViewPath,
      builder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        final responseId = extra['responseId'] as int;
        return CompletedResponseViewPage(responseId: responseId);
      },
    ),
    GoRoute(
      path: Routes.publicLinkAnsweringPath,
      builder: (context, state) {
        final args = state.extra as PublicLinkAnsweringArgs;
        return PublicLinkAnsweringPage(
          shortCode: args.shortCode,
          surveyTitle: args.surveyTitle,
          requireLocation: args.requireLocation,
          goodbyeMessage: args.goodbyeMessage,
        );
      },
    ),
  ],
);
