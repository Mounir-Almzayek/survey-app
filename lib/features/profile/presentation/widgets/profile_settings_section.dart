import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../widgets/profile_logout_dialog.dart';
import 'profile_menu_tile.dart';
import 'language_selection_dialog.dart';

class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileMenuTile(
            icon: Icons.language_rounded,
            title: s.language,
            onTap: () => LanguageSelectionDialog.show(context),
          ),
          const Divider(height: 1),
          ProfileMenuTile(
            icon: Icons.notifications_outlined,
            title: s.notifications,
            onTap: () {},
          ),
          const Divider(height: 1),
          ProfileMenuTile(
            icon: Icons.logout_rounded,
            title: s.log_out,
            isDestructive: true,
            onTap: () => ProfileLogoutDialog.show(context),
          ),
        ],
      ),
    );
  }
}
