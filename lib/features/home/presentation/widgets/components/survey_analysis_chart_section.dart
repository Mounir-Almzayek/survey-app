import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/models/survey/researcher_quota_model.dart';
import '../../../../../core/models/survey/survey_model.dart';
import '../../../../../core/styles/app_colors.dart';
import '../../../../../core/utils/responsive_layout.dart';
import '../../../../../core/widgets/custom_dropdown_field.dart';
import 'chart_container.dart';

/// Survey selector + bar chart of quota completion per demographic.
/// Replaces carousel with a single chart and dropdown for researcher-focused analytics.
class SurveyAnalysisChartSection extends StatefulWidget {
  final List<Survey> surveys;

  const SurveyAnalysisChartSection({super.key, required this.surveys});

  @override
  State<SurveyAnalysisChartSection> createState() =>
      _SurveyAnalysisChartSectionState();
}

class _SurveyAnalysisChartSectionState
    extends State<SurveyAnalysisChartSection> {
  Survey? _selectedSurvey;

  @override
  Widget build(BuildContext context) {
    if (widget.surveys.isEmpty) return const SizedBox.shrink();

    final s = S.of(context);

    final isDesktop = context.isDesktop;
    final maxSectionWidth = isDesktop ? 580.0 : double.infinity;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxSectionWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selectedSurvey != null)
            _buildQuotaChart(context, _selectedSurvey!, s)
          else
            _buildPlaceholder(context, s),
          SizedBox(
            height: context.responsive(16.h, tablet: 20.h, desktop: 24.0),
          ),
          CustomDropdownField<Survey>(
            label: s.surveys,
            items: widget.surveys,
            selectedValue: _selectedSurvey,
            onChanged: (survey) => setState(() => _selectedSurvey = survey),
            getLabel: (survey) => survey.title ?? 'Survey #${survey.id}',
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, S s) {
    final padding = context.responsive(24.r, tablet: 28.r, desktop: 32.0);
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(
          context.responsive(20.r, tablet: 22.r, desktop: 24.0),
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          s.please_select,
          style: TextStyle(
            fontSize: context.responsive(14.sp, tablet: 15.sp, desktop: 15.0),
            color: AppColors.secondaryText,
          ),
        ),
      ),
    );
  }

  Widget _buildQuotaChart(BuildContext context, Survey survey, S s) {
    final assignments = survey.assignments;
    final quotas =
        (assignments != null &&
            assignments.isNotEmpty &&
            assignments.first.researcherQuotas != null)
        ? assignments.first.researcherQuotas!
        : <ResearcherQuota>[];

    if (quotas.isEmpty) {
      return ChartContainer(
        title: s.target_categories,
        icon: Icons.bar_chart_rounded,
        iconColor: AppColors.primary,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Center(
            child: Text(
              'No quota data',
              style: TextStyle(
                fontSize: context.adaptiveFont(13.sp),
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ),
      );
    }

    final chartHeight = context.responsive(
      220.h,
      tablet: 260.h,
      desktop: 320.0,
    );
    final leftReserved = context.responsive(28.w, tablet: 32.w, desktop: 44.0);
    final bottomReserved = context.responsive(
      44.h,
      tablet: 50.h,
      desktop: 60.0,
    );
    final barWidth = context.responsive(20.w, tablet: 24.w, desktop: 32.0);
    final fontSizeLabel = context.responsive(
      9.sp,
      tablet: 10.sp,
      desktop: 11.0,
    );
    final fontSizeLeft = context.responsive(
      10.sp,
      tablet: 11.sp,
      desktop: 12.0,
    );

    return ChartContainer(
      title: s.target_categories,
      icon: Icons.bar_chart_rounded,
      iconColor: AppColors.primary,
      child: SizedBox(
        height: chartHeight,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 100,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => AppColors.card,
                getTooltipItem: (group, groupIndex, rod, rodIndex) => null,
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: bottomReserved,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < quotas.length) {
                      final q = quotas[value.toInt()];
                      final label = _shortLabel(q.demographicDescription);
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: fontSizeLabel,
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: leftReserved,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}%',
                      style: TextStyle(
                        fontSize: fontSizeLeft,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                  interval: 25,
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (value) => FlLine(
                color: AppColors.border.withOpacity(0.5),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: quotas.asMap().entries.map((entry) {
              final i = entry.key;
              final q = entry.value;
              final pct = q.completionPercentage.clamp(0.0, 100.0);
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: pct,
                    color: AppColors.primary.withOpacity(
                      q.progressDisplayAlpha,
                    ),
                    width: barWidth,
                    borderRadius: BorderRadius.circular(
                      context.responsive(6.r, desktop: 8.0),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: 100,
                      color: AppColors.muted.withOpacity(0.3),
                    ),
                  ),
                ],
                showingTooltipIndicators: [0],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  String _shortLabel(String demographicDescription) {
    if (demographicDescription.length <= 12) return demographicDescription;
    final parts = demographicDescription.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]}\n${parts.sublist(1).join(' ')}';
    }
    return '${demographicDescription.substring(0, 6)}…';
  }
}
