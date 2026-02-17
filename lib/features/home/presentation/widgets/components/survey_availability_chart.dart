import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/styles/app_colors.dart';
import '../../../../../core/utils/responsive_layout.dart';
import '../../../models/survey_stats_model.dart';
import 'chart_container.dart';

class SurveyAvailabilityChart extends StatelessWidget {
  final SurveyStatsModel stats;

  const SurveyAvailabilityChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ChartContainer(
      title: s.survey_availability,
      icon: Icons.calendar_month_rounded,
      iconColor: Colors.blue,
      child: SizedBox(
        height: 240.h,
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
    );
  }
}
