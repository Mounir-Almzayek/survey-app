import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/scroll_reveal.dart';
import '../../models/survey_stats_model.dart';
import 'components/dashboard_metrics.dart';
import 'components/survey_analysis_chart_section.dart';
import 'components/sync_status_chart.dart';

class SurveyStatsWidget extends StatelessWidget {
  final SurveyStatsModel stats;
  final bool isSidebarLayout;
  final GlobalKey analysisKey;
  final GlobalKey metricsKey;
  final GlobalKey syncKey;

  const SurveyStatsWidget({
    super.key,
    required this.stats,
    required this.analysisKey,
    required this.metricsKey,
    required this.syncKey,
    this.isSidebarLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSidebarLayout) {
      return DashboardMetrics(stats: stats);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stats.surveysWithQuotas.isNotEmpty)
          ScrollReveal(
            key: analysisKey,
            delay: const Duration(milliseconds: 200),
            child: SurveyAnalysisChartSection(surveys: stats.surveysWithQuotas),
          ),

        if (stats.surveysWithQuotas.isNotEmpty) SizedBox(height: 24.h),

        ScrollReveal(
          key: metricsKey,
          delay: const Duration(milliseconds: 400),
          child: DashboardMetrics(stats: stats),
        ),
        SizedBox(height: 24.h),

        ScrollReveal(
          key: syncKey,
          delay: const Duration(milliseconds: 600),
          child: SyncStatusChart(stats: stats),
        ),
      ],
    );
  }
}
