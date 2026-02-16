import 'package:flutter/material.dart';

import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/styles/app_colors.dart';
import '../../../../../core/utils/responsive_layout.dart';
import '../../../models/survey_stats_model.dart';
import 'metric_card.dart';

class DashboardMetrics extends StatelessWidget {
  final SurveyStatsModel stats;

  const DashboardMetrics({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: context.responsive(2, tablet: 3, desktop: 2),
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
      childAspectRatio: context.responsive(1.4, tablet: 1.5, desktop: 1.8),
      children: _getMetricCards(s),
    );
  }

  List<Widget> _getMetricCards(S s) {
    return [
      MetricCard(
        label: s.active_surveys,
        value: stats.activeSurveys.toString(),
        icon: Icons.play_circle_filled_rounded,
        color: AppColors.success,
      ),
      MetricCard(
        label: s.draft_responses,
        value: stats.draftResponses.toString(),
        icon: Icons.edit_document,
        color: AppColors.warning,
      ),
      MetricCard(
        label: s.pending_sync,
        value: stats.pendingSyncResponses.toString(),
        icon: Icons.sync_problem_rounded,
        color: AppColors.error,
      ),
      MetricCard(
        label: s.synced_responses,
        value: stats.syncedResponses.toString(),
        icon: Icons.cloud_done_rounded,
        color: AppColors.primary,
      ),
    ];
  }
}
