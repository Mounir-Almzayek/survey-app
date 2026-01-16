import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../responses/models/response.dart';
import '../../../responses/models/response_status.dart';

class CompletedResponseCard extends StatelessWidget {
  final ResponseSummary response;
  final VoidCallback onTap;

  const CompletedResponseCard({
    super.key,
    required this.response,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.border, width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatId(response.id),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText,
                              ),
                            ),
                            if (response.survey?.title != null)
                              Text(
                                response.survey!.title!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(response.status),
              ],
            ),
            const SizedBox(height: 16),
            // Completion Date and Time
            if (response.endedAt != null)
              _buildInfoRow(
                icon: Icons.check_circle_outline_rounded,
                iconColor: AppColors.success,
                label: 'Completed at',
                value: dateTimeFormat.format(response.endedAt!),
              ),
            const SizedBox(height: 8),
            // Survey Expiration Date and Time
            if (response.survey?.availabilityEndAt != null)
              _buildInfoRow(
                icon: Icons.event_outlined,
                iconColor: AppColors.warning,
                label: 'Survey expires at',
                value: dateTimeFormat.format(
                  response.survey!.availabilityEndAt!,
                ),
              ),
            const SizedBox(height: 8),
            // Duration
            _buildInfoRow(
              icon: Icons.timer_outlined,
              iconColor: AppColors.secondaryText,
              label: 'Duration',
              value: _formatDuration(response.durationSec),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText.withOpacity(0.8),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(ResponseStatus status) {
    String label;
    Color color;

    switch (status) {
      case ResponseStatus.submitted:
        label = 'Submitted';
        color = AppColors.success;
        break;
      case ResponseStatus.flagged:
        label = 'Flagged';
        color = AppColors.warning;
        break;
      case ResponseStatus.rejected:
        label = 'Rejected';
        color = AppColors.error;
        break;
      case ResponseStatus.draft:
        label = 'Draft';
        color = AppColors.secondaryText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _formatId(int id) {
    final s = id.toString();
    return 'Response #${s.length >= 3 ? s : s.padLeft(3, '0')}';
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds seconds';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return remainingSeconds > 0
          ? '$minutes min $remainingSeconds sec'
          : '$minutes min';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return minutes > 0 ? '$hours h $minutes min' : '$hours h';
    }
  }
}
