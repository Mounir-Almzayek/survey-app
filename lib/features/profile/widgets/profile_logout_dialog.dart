import 'package:flutter/material.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';

class ProfileLogoutDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ProfileLogoutDialog({super.key, required this.onConfirm});

  static Future<void> show(BuildContext context, VoidCallback onConfirm) {
    return showDialog(
      context: context,
      builder: (context) => ProfileLogoutDialog(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    return AlertDialog(
      title: Text(locale.logout_title),
      content: Text(locale.logout_message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            locale.cancel,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: Text(locale.confirm),
        ),
      ],
    );
  }
}
