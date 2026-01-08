import 'package:flutter/material.dart';
import '../../../core/l10n/generated/l10n.dart';

/// Main navigation tabs for the app
enum MainNavTab { home, surveys, custody, profile }

extension MainNavTabX on MainNavTab {
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

/// Tabs to show in the bottom navigation bar
List<MainNavTab> get bottomNavTabs => MainNavTab.values;
