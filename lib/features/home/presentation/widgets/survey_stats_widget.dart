import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
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
        // 1. Modern Metric Cards (Top Row)
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 14.h,
          crossAxisSpacing: 14.w,
          childAspectRatio: 1,
          children: [
            _MetricCard(
              label: s.assignments,
              value: stats.totalAssignments.toString(),
              icon: Icons.assignment_rounded,
              color: AppColors.primary,
            ),
            _MetricCard(
              label: s.offline_drafts,
              value: stats.offlineDrafts.toString(),
              icon: Icons.cloud_off_rounded,
              color: AppColors.warning,
            ),
            _MetricCard(
              label: s.completed,
              value: stats.syncedResponses.toString(),
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
            ),
            _MetricCard(
              label: s.completion_rate,
              value: "${stats.completionRate.toStringAsFixed(1)}%",
              icon: Icons.auto_graph_rounded,
              color: AppColors.accent,
            ),
          ],
        ),
        SizedBox(height: 24.h),

        // 2. Advanced Analysis Card (Web Design Layout)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(20.r),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.insert_chart_rounded,
                        color: AppColors.primary,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Text(
                      s.survey_overview,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),

              // Chart and Legend Side-by-Side
              Padding(
                padding: EdgeInsets.fromLTRB(20.r, 0, 20.r, 24.r),
                child: Row(
                  children: [
                    // Donut Chart
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 160.h,
                        child: Stack(
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 4,
                                centerSpaceRadius: 45.r,
                                sections: _getSections(stats),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    (stats.totalAssignments +
                                            stats.offlineDrafts +
                                            stats.syncedResponses)
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                  Text(
                                    s.total.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.secondaryText,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 24.w),

                    // Web-style Legend
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _WebLegendItem(
                            color: AppColors.primary,
                            label: s.assignments,
                            value: stats.totalAssignments,
                            total:
                                stats.totalAssignments +
                                stats.offlineDrafts +
                                stats.syncedResponses,
                          ),
                          _WebLegendItem(
                            color: AppColors.warning,
                            label: s.offline_drafts,
                            value: stats.offlineDrafts,
                            total:
                                stats.totalAssignments +
                                stats.offlineDrafts +
                                stats.syncedResponses,
                          ),
                          _WebLegendItem(
                            color: AppColors.success,
                            label: s.completed,
                            value: stats.syncedResponses,
                            total:
                                stats.totalAssignments +
                                stats.offlineDrafts +
                                stats.syncedResponses,
                          ),
                        ],
                      ),
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

  List<PieChartSectionData> _getSections(SurveyStatsModel stats) {
    final total =
        (stats.totalAssignments + stats.offlineDrafts + stats.syncedResponses)
            .toDouble();

    if (total == 0) {
      return [
        PieChartSectionData(
          color: AppColors.border.withValues(alpha: 0.3),
          value: 1,
          title: '',
          radius: 35.r,
        ),
      ];
    }

    return [
      _buildSection(AppColors.primary, stats.totalAssignments.toDouble(), 35.r),
      _buildSection(AppColors.warning, stats.offlineDrafts.toDouble(), 35.r),
      _buildSection(AppColors.success, stats.syncedResponses.toDouble(), 35.r),
    ];
  }

  PieChartSectionData _buildSection(Color color, double value, double radius) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: '',
      radius: radius,
    );
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
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryText,
            ),
          ),
          const Spacer(),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _WebLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  final int total;

  const _WebLegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = total > 0 ? (value / total) * 100 : 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryText,
              ),
            ),
          ),
          Text(
            "${percentage.toStringAsFixed(0)}%",
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
