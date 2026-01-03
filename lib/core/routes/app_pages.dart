import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/welcome/presentation/welcome_page.dart';
import '../../features/main_screen/presentation/main_page.dart';
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
  ],
);

