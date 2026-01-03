import 'package:flutter/material.dart';
import '../../../core/l10n/generated/l10n.dart';

/// Main navigation tabs for the app
enum MainNavTab {
  home,
  profile,
}

extension MainNavTabX on MainNavTab {
  IconData get icon {
    switch (this) {
      case MainNavTab.home:
        return Icons.bar_chart_rounded;
      case MainNavTab.profile:
        return Icons.person_outline_rounded;
    }
  }

  String label(S locale) {
    switch (this) {
      case MainNavTab.home:
        return locale.statistics;
      case MainNavTab.profile:
        return locale.profile;
    }
  }
}

/// Tabs to show in the bottom navigation bar
List<MainNavTab> get bottomNavTabs => [
      MainNavTab.home,
      MainNavTab.profile,
    ];

