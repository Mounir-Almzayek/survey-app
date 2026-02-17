import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/scroll_reveal.dart';
import '../../models/survey_stats_model.dart';
import 'demographic_charts.dart';
import 'components/dashboard_metrics.dart';
import 'components/survey_analysis_chart_section.dart';
import 'components/survey_availability_chart.dart';
import 'components/sync_status_chart.dart';

class SurveyStatsWidget extends StatelessWidget {
  final SurveyStatsModel stats;
  final bool isSidebarLayout;
  final GlobalKey analysisKey;
  final GlobalKey demographicsKey;
  final GlobalKey availabilityKey;
  final GlobalKey metricsKey;
  final GlobalKey syncKey;

  const SurveyStatsWidget({
    super.key,
    required this.stats,
    required this.analysisKey,
    required this.demographicsKey,
    required this.availabilityKey,
    required this.metricsKey,
    required this.syncKey,
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
        // 1. Survey analysis: select survey + quota bar chart
        if (stats.surveysWithQuotas.isNotEmpty)
          ScrollReveal(
            key: analysisKey,
            delay: const Duration(milliseconds: 200),
            child: SurveyAnalysisChartSection(surveys: stats.surveysWithQuotas),
          ),

        if (stats.surveysWithQuotas.isNotEmpty) SizedBox(height: 24.h),

        // 2. Demographic Charts
        ScrollReveal(
          key: demographicsKey,
          delay: const Duration(milliseconds: 400),
          child: DemographicCharts(
            genderProgress: stats.genderProgress,
            ageGroupProgress: stats.ageGroupProgress,
          ),
        ),
        SizedBox(height: 24.h),

        // 3. Availability Chart
        ScrollReveal(
          key: availabilityKey,
          delay: const Duration(milliseconds: 600),
          child: SurveyAvailabilityChart(stats: stats),
        ),
        SizedBox(height: 16.h),

        // 4. Metric Grid (Actionable Insights)
        ScrollReveal(
          key: metricsKey,
          delay: const Duration(milliseconds: 800),
          child: DashboardMetrics(stats: stats),
        ),
        SizedBox(height: 24.h),

        // 5. Sync Status Chart
        ScrollReveal(
          key: syncKey,
          delay: const Duration(milliseconds: 1000),
          child: SyncStatusChart(stats: stats),
        ),
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
