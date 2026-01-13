import 'package:flutter/material.dart';

import '../../models/response.dart';
import '../../models/response_status.dart';

class ResponseCard extends StatelessWidget {
  final ResponseSummary response;
  final VoidCallback? onView;
  final VoidCallback? onReview;

  const ResponseCard({
    super.key,
    required this.response,
    this.onView,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatId(response.id),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(response.status),
              ],
            ),
            const SizedBox(height: 8),
            if (response.survey != null)
              Text(
                response.survey!.title ?? "",
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${response.durationSec}s',
                  style: theme.textTheme.labelMedium,
                ),
                const Spacer(),
                if (onReview != null)
                  TextButton(onPressed: onReview, child: const Text('Review')),
                if (onView != null)
                  TextButton(onPressed: onView, child: const Text('View')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatId(int id) {
    final s = id.toString();
    return 'R-${s.length >= 3 ? s : s.padLeft(3, '0')}';
  }

  Widget _buildStatusChip(ResponseStatus status) {
    String label;
    Color color;

    switch (status) {
      case ResponseStatus.submitted:
        label = 'Submitted';
        color = Colors.blue;
        break;
      case ResponseStatus.flagged:
        label = 'Flagged';
        color = Colors.orange;
        break;
      case ResponseStatus.rejected:
        label = 'Rejected';
        color = Colors.red;
        break;
      case ResponseStatus.draft:
        label = 'Draft';
        color = Colors.grey;
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
