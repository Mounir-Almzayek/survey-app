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
      title: s.gender,
      icon: Icons.people_outline,
      iconColor: AppColors.primary,
      child: SizedBox(
        height: 200.h,
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 1,
                  centerSpaceRadius: 30.r,
                  sections: genderProgress.entries.map((entry) {
                    final normalizedKey = entry.key.toLowerCase();
                    final color = normalizedKey == 'male'
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
                  final normalizedKey = entry.key.toLowerCase();
                  final color = normalizedKey == 'male'
                      ? Colors.blue.withOpacity(0.8)
                      : Colors.pink.withOpacity(0.8);

                  String label = entry.key;
                  if (normalizedKey == 'male') label = s.gender_male;
                  if (normalizedKey == 'female') label = s.gender_female;

                  return LegendItem(
                    color: color,
                    label: label,
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
    final count = ageGroupProgress.length;
    return ChartContainer(
      title: s.age_group,
      icon: Icons.bar_chart_rounded,
      iconColor: AppColors.warning,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minChartWidth = (count * 68.0)
              .clamp(68.0, double.infinity)
              .toDouble();
          final chartWidth = minChartWidth > constraints.maxWidth
              ? minChartWidth
              : constraints.maxWidth;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth,
              height: 280.h,
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
                        reservedSize: 90.h,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < ageGroupProgress.length) {
                            final rawKey = ageGroupProgress.keys.elementAt(
                              value.toInt(),
                            );

                            // Map raw key to localized string
                            String label = _localizeAgeKey(rawKey, s);

                            return SideTitleWidget(
                              meta: meta,
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: context.adaptiveFont(11.sp),
                                    color: AppColors.secondaryText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                  barGroups: ageGroupProgress.entries
                      .toList()
                      .asMap()
                      .entries
                      .map((e) {
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
                      })
                      .toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _localizeAgeKey(String key, S s) {
    final normalized = key
        .toLowerCase()
        .replaceAll('age', '')
        .replaceAll('_', '-')
        .replaceAll(' ', '');
    if (normalized == '18-29') return s.age_18_29;
    if (normalized == '30-39') return s.age_30_39;
    if (normalized == '40-49') return s.age_40_49;
    if (normalized == '50-59') return s.age_50_59;
    if (normalized == '60-69') return s.age_60_69;
    if (normalized == '70-79') return s.age_70_79;
    if (normalized == '80-89') return s.age_80_89;
    if (normalized == '90-99') return s.age_90_99;
    if (normalized == '100plus' || normalized == '100+') return s.age_100_plus;

    // Fallback logic for raw strings from API
    return key.replaceAll('Group_', '').replaceAll('plus', '+');
  }
}
