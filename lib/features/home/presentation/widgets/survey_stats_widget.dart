import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/survey_stats_model.dart';
import 'demographic_charts.dart';
import 'components/dashboard_metrics.dart';
import 'components/survey_analysis_chart_section.dart';
import 'components/survey_availability_chart.dart';
import 'components/sync_status_chart.dart';

class SurveyStatsWidget extends StatelessWidget {
  final SurveyStatsModel stats;
  final bool isSidebarLayout;

  const SurveyStatsWidget({
    super.key,
    required this.stats,
    this.isSidebarLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSidebarLayout) {
      // For sidebar, we might validly want a vertical list of metrics,
      // but strictly following the refactor, we can wrap DashboardMetrics or adapt it.
      // For now, let's keep it simple and just show the metrics since that was the previous sidebar behavior logic roughly.
      return DashboardMetrics(stats: stats);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Metric Grid (Actionable Insights)
        DashboardMetrics(stats: stats),
        SizedBox(height: 24.h),

        // 2. Survey analysis: select survey + quota bar chart
        if (stats.surveysWithQuotas.isNotEmpty)
          SurveyAnalysisChartSection(surveys: stats.surveysWithQuotas),

        if (stats.surveysWithQuotas.isNotEmpty) SizedBox(height: 24.h),

        // 3. Demographic Charts
        DemographicCharts(
          genderProgress: stats.genderProgress,
          ageGroupProgress: stats.ageGroupProgress,
        ),
        SizedBox(height: 24.h),

        // 4. Availability Chart
        SurveyAvailabilityChart(stats: stats),
        SizedBox(height: 16.h),

        // 5. Sync Status Chart
        SyncStatusChart(stats: stats),
      ],
    );
  }
}

class SurveyChartsOnly extends StatelessWidget {
  final SurveyStatsModel stats;
  const SurveyChartsOnly({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SurveyAvailabilityChart(stats: stats),
        SizedBox(height: 16.h),
        SyncStatusChart(stats: stats),
      ],
    );
  }
}
