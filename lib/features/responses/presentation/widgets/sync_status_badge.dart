import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../models/response_status.dart';

class SyncStatusBadge extends StatelessWidget {
  final ResponseStatus status;

  const SyncStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    final locale = S.of(context);

    switch (status) {
      case ResponseStatus.submitted:
        label = locale.response_status_synced;
        color = Colors.green;
        break;
      case ResponseStatus.draft:
        label = locale.response_status_pending;
        color = Colors.orange;
        break;
      case ResponseStatus.flagged:
        label = locale.response_status_flagged;
        color = Colors.yellow.shade800;
        break;
      case ResponseStatus.rejected:
        label = locale.response_status_rejected;
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}


