import 'package:flutter/material.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../auth/models/login_method_type.dart';
import 'nav_visibility_context.dart';

/// Main navigation tabs for the app
enum MainNavTab { home, surveys, custody, profile }

extension MainNavTabX on MainNavTab {
  /// Whether this tab is visible given the current nav visibility context.
  /// Extensible: add more conditions per case as needed.
  bool isVisible(NavVisibilityContext ctx) {
    switch (this) {
      case MainNavTab.custody:
        return ctx.loginMethod != LoginMethodType.emailOnly;
      case MainNavTab.home:
      case MainNavTab.surveys:
      case MainNavTab.profile:
        return true;
    }
  }

  IconData get icon {
    switch (this) {
      case MainNavTab.home:
        return Icons.dashboard_outlined;
      case MainNavTab.surveys:
        return Icons.assignment_outlined;
      case MainNavTab.custody:
        return Icons.security_outlined;
      case MainNavTab.profile:
        return Icons.person_outline_rounded;
    }
  }

  IconData get activeIcon {
    switch (this) {
      case MainNavTab.home:
        return Icons.dashboard_rounded;
      case MainNavTab.surveys:
        return Icons.assignment_rounded;
      case MainNavTab.custody:
        return Icons.security_rounded;
      case MainNavTab.profile:
        return Icons.person_rounded;
    }
  }

  String label(S locale) {
    switch (this) {
      case MainNavTab.home:
        return locale.home;
      case MainNavTab.surveys:
        return locale.surveys;
      case MainNavTab.custody:
        return locale.custody;
      case MainNavTab.profile:
        return locale.profile;
    }
  }
}

/// Visible tabs for the given context. Single source for drawer, bottom bar, sidebar.
List<MainNavTab> visibleTabs(NavVisibilityContext ctx) =>
    MainNavTab.values.where((t) => t.isVisible(ctx)).toList();
