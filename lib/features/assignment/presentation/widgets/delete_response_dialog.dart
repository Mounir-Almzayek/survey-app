import 'package:flutter/material.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';

class DeleteResponseDialog extends StatelessWidget {
  final int responseId;

  const DeleteResponseDialog({super.key, required this.responseId});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        s.confirm_delete_title,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      ),
      content: Text(
        s.confirm_delete_message(responseId),
        textAlign: TextAlign.right,
        style: const TextStyle(color: AppColors.secondaryText),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            s.cancel,
            style: const TextStyle(color: AppColors.secondaryText),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            minimumSize: const Size(80, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(s.delete),
        ),
      ],
    );
  }
}
