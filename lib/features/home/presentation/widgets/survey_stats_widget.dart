import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../models/survey_stats_model.dart';

class SurveyStatsWidget extends StatelessWidget {
  final SurveyStatsModel stats;

  const SurveyStatsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Metric Grid (Actionable Insights)
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: context.responsive(2, tablet: 3, desktop: 4),
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: context.responsive(1.4, tablet: 1.6, desktop: 1.8),
          children: [
            _MetricCard(
              label: s.active_surveys,
              value: stats.activeSurveys.toString(),
              icon: Icons.play_circle_filled_rounded,
              color: AppColors.success,
            ),
            _MetricCard(
              label: s.draft_responses,
              value: stats.draftResponses.toString(),
              icon: Icons.edit_document,
              color: AppColors.warning,
            ),
            _MetricCard(
              label: s.pending_sync,
              value: stats.pendingSyncResponses.toString(),
              icon: Icons.sync_problem_rounded,
              color: AppColors.error,
            ),
            _MetricCard(
              label: s.synced_responses,
              value: stats.syncedResponses.toString(),
              icon: Icons.cloud_done_rounded,
              color: AppColors.primary,
            ),
          ],
        ),
        SizedBox(height: 24.h),

        // 2. Availability Analysis (Bar Chart)
        _ChartContainer(
          title: s.survey_availability,
          icon: Icons.calendar_month_rounded,
          iconColor: Colors.blue,
          child: SizedBox(
            height: 180.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (stats.totalSurveys + 2).toDouble(),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        switch (value.toInt()) {
                          case 0:
                            text = s.upcoming_surveys;
                            break;
                          case 1:
                            text = s.active_surveys;
                            break;
                          case 2:
                            text = s.expired_surveys;
                            break;
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            text,
                            style: TextStyle(
                              fontSize: context.adaptiveFont(9.sp),
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: stats.upcomingSurveys.toDouble(),
                        color: Colors.blue.withOpacity(0.7),
                        width: 20.w,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: stats.activeSurveys.toDouble(),
                        color: AppColors.success.withOpacity(0.7),
                        width: 20.w,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: stats.expiredSurveys.toDouble(),
                        color: AppColors.error.withOpacity(0.7),
                        width: 20.w,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // 3. Sync Status (Donut Chart)
        _ChartContainer(
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
                    _LegendItem(
                      color: AppColors.primary,
                      label: s.synced_responses,
                      value: stats.syncedResponses,
                    ),
                    _LegendItem(
                      color: AppColors.error,
                      label: s.pending_sync,
                      value: stats.pendingSyncResponses,
                    ),
                    _LegendItem(
                      color: AppColors.warning,
                      label: s.draft_responses,
                      value: stats.draftResponses,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: context.adaptiveIcon(18.sp),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: context.adaptiveFont(16.sp),
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: context.adaptiveFont(11.sp),
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _ChartContainer({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: context.adaptiveIcon(16.sp)),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: context.adaptiveFont(13.sp),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: context.adaptiveFont(10.sp),
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: context.adaptiveFont(10.sp),
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
