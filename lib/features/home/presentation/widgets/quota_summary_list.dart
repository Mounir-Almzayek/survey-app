import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/models/survey/survey_model.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../models/survey_stats_model.dart';
import 'quota_breakdown_list.dart';

class QuotaSummaryList extends StatelessWidget {
  final List<Survey> surveys;
  final Map<int, List<QuotaBreakdownEntry>> breakdownBySurveyId;

  const QuotaSummaryList({
    super.key,
    required this.surveys,
    this.breakdownBySurveyId = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) return const SizedBox.shrink();

    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            s.target_categories,
            style: TextStyle(
              fontSize: context.adaptiveFont(16.sp),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: surveys.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            return _buildSurveyQuotaCard(
              context,
              surveys[index],
              breakdownBySurveyId[surveys[index].id] ?? const [],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSurveyQuotaCard(
    BuildContext context,
    Survey survey,
    List<QuotaBreakdownEntry> breakdown,
  ) {
    int totalTarget = 0;
    int totalProgress = 0;

    if (survey.assignments != null &&
        survey.assignments!.isNotEmpty &&
        survey.assignments!.first.researcherQuotas != null) {
      for (var quota in survey.assignments!.first.researcherQuotas!) {
        totalTarget += quota.target;
        totalProgress += quota.progress;
      }
    }

    final percent = totalTarget > 0 ? totalProgress / totalTarget : 0.0;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  survey.title ?? '',
                  style: TextStyle(
                    fontSize: context.adaptiveFont(13.sp),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(percent * 100).toInt()}%',
                style: TextStyle(
                  fontSize: context.adaptiveFont(13.sp),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              backgroundColor: AppColors.muted,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8.h,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '$totalProgress / $totalTarget',
            style: TextStyle(
              fontSize: context.adaptiveFont(11.sp),
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (breakdown.isNotEmpty) ...[
            SizedBox(height: 12.h),
            const Divider(height: 1),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: Text(
                'عرض التفاصيل',
                style: TextStyle(
                  fontSize: context.adaptiveFont(12.sp),
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              children: [
                QuotaBreakdownList(entries: breakdown, topN: 5),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
