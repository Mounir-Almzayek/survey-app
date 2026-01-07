import 'package:flutter/material.dart';

import '../../models/assignment.dart';
import '../../models/survey_status.dart';

class SurveyCard extends StatelessWidget {
  final Assignment assignment;
  final VoidCallback? onTap;

  const SurveyCard({
    super.key,
    required this.assignment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final survey = assignment.survey;
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      survey?.title ?? 'Untitled survey',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(survey?.status),
                ],
              ),
              const SizedBox(height: 8),
              if ((survey?.description ?? '').isNotEmpty)
                Text(
                  survey!.description,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.hintColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (survey != null)
                    Text(
                      survey.lang.toUpperCase(),
                      style: theme.textTheme.labelMedium,
                    ),
                  const Spacer(),
                  if (assignment.responsesCount != null)
                    Text(
                      '${assignment.responsesCount} responses',
                      style: theme.textTheme.labelMedium,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(SurveyStatus? status) {
    final label = switch (status) {
      SurveyStatus.draft => 'DRAFT',
      SurveyStatus.published => 'PUBLISHED',
      SurveyStatus.archived => 'ARCHIVED',
      null => 'UNKNOWN',
    };

    Color color;
    switch (status) {
      case SurveyStatus.draft:
        color = Colors.grey;
        break;
      case SurveyStatus.published:
        color = Colors.green;
        break;
      case SurveyStatus.archived:
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
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


