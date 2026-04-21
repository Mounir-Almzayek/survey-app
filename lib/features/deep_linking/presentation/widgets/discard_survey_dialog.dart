import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';

Future<bool> showDiscardSurveyDialog(BuildContext context) async {
  final s = S.of(context);
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(s.discard_survey_title),
      content: Text(s.discard_survey_message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(s.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(s.discard),
        ),
      ],
    ),
  );
  return result ?? false;
}
