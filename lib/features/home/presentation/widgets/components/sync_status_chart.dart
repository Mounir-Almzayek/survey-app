import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/styles/app_colors.dart';
import '../../../../../core/utils/responsive_layout.dart';
import '../../../models/survey_stats_model.dart';
import 'chart_container.dart';
import 'legend_item.dart';

class SyncStatusChart extends StatelessWidget {
  final SurveyStatsModel stats;

  const SyncStatusChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ChartContainer(
      title: s.sync_status,
      icon: Icons.sync_rounded,
      iconColor: AppColors.primary,
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: SizedBox(
              height: 140.h,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 35.r,
                      sections: _getSyncSections(stats, s),
                    ),
                  ),
                  Center(
                    child: Text(
                      (stats.syncedResponses +
                              stats.pendingSyncResponses +
                              stats.draftResponses)
                          .toString(),
                      style: TextStyle(
                        fontSize: context.adaptiveFont(16.sp),
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LegendItem(
                  color: AppColors.primary,
                  label: s.synced_responses,
                  value: stats.syncedResponses.toString(),
                ),
                LegendItem(
                  color: AppColors.error,
                  label: s.pending_sync,
                  value: stats.pendingSyncResponses.toString(),
                ),
                LegendItem(
                  color: AppColors.warning,
                  label: s.draft_responses,
                  value: stats.draftResponses.toString(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getSyncSections(SurveyStatsModel stats, S s) {
    final total =
        (stats.syncedResponses +
                stats.pendingSyncResponses +
                stats.draftResponses)
            .toDouble();

    if (total == 0) {
      return [
        PieChartSectionData(
          color: AppColors.border.withOpacity(0.3),
          value: 1,
          title: '',
          radius: 20.r,
        ),
      ];
    }

    return [
      PieChartSectionData(
        color: AppColors.primary,
        value: stats.syncedResponses.toDouble(),
        title: '',
        radius: 20.r,
      ),
      PieChartSectionData(
        color: AppColors.error,
        value: stats.pendingSyncResponses.toDouble(),
        title: '',
        radius: 20.r,
      ),
      PieChartSectionData(
        color: AppColors.warning,
        value: stats.draftResponses.toDouble(),
        title: '',
        radius: 20.r,
      ),
    ];
  }
}
