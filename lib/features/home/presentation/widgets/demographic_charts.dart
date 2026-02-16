import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import 'components/chart_container.dart';
import 'components/legend_item.dart';

class DemographicCharts extends StatelessWidget {
  final Map<String, double> genderProgress;
  final Map<String, double> ageGroupProgress;

  const DemographicCharts({
    super.key,
    required this.genderProgress,
    required this.ageGroupProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (genderProgress.isEmpty && ageGroupProgress.isEmpty) {
      return const SizedBox.shrink();
    }

    final s = S.of(context);

    return Column(
      children: [
        if (genderProgress.isNotEmpty) _buildGenderChart(context, s),
        if (genderProgress.isNotEmpty && ageGroupProgress.isNotEmpty)
          SizedBox(height: 16.h),
        if (ageGroupProgress.isNotEmpty) _buildAgeGroupChart(context, s),
      ],
    );
  }

  Widget _buildGenderChart(BuildContext context, S s) {
    return ChartContainer(
      title: s.gender, // Ensure "Gender" key exists or use fallback
      icon: Icons.people_outline,
      iconColor: AppColors.primary,
      child: SizedBox(
        height: 150.h,
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 1,
                  centerSpaceRadius: 30.r,
                  sections: genderProgress.entries.map((entry) {
                    final color = entry.key == 'male' || entry.key == 'Male'
                        ? Colors.blue.withOpacity(0.8)
                        : Colors.pink.withOpacity(0.8);
                    final value = entry.value * 100;
                    return PieChartSectionData(
                      color: color,
                      value: value,
                      title: '${value.toInt()}%',
                      radius: 30.r,
                      titleStyle: TextStyle(
                        fontSize: context.adaptiveFont(12.sp),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: genderProgress.entries.map((entry) {
                  final color = entry.key == 'male' || entry.key == 'Male'
                      ? Colors.blue.withOpacity(0.8)
                      : Colors.pink.withOpacity(0.8);
                  return LegendItem(
                    color: color,
                    label: entry.key,
                    value: '${(entry.value * 100).toInt()}%',
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeGroupChart(BuildContext context, S s) {
    return ChartContainer(
      title: s.age_group, // Ensure "Age Group" key exists or use fallback
      icon: Icons.bar_chart_rounded,
      iconColor: AppColors.warning,
      child: SizedBox(
        height: 200.h,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 100,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => AppColors.card,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toInt()}%',
                    TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 &&
                        value.toInt() < ageGroupProgress.length) {
                      final key = ageGroupProgress.keys.elementAt(
                        value.toInt(),
                      );
                      // Shorten key if too long
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          key.replaceAll('Group_', '').replaceAll('plus', '+'),
                          style: TextStyle(
                            fontSize: context.adaptiveFont(10.sp),
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: ageGroupProgress.entries.toList().asMap().entries.map((
              e,
            ) {
              final index = e.key;
              final value = e.value.value * 100;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: value,
                    color: AppColors.primary.withOpacity(0.7),
                    width: 16.w,
                    borderRadius: BorderRadius.circular(4.r),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: 100,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
