import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/models/survey/survey_model.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';

class QuotaSummaryList extends StatelessWidget {
  final List<Survey> surveys;

  const QuotaSummaryList({super.key, required this.surveys});

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
            s.target_categories, // Reuse "Target Categories" or add "Quota Summary" key
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
            return _buildSurveyQuotaCard(context, surveys[index]);
          },
        ),
      ],
    );
  }

  Widget _buildSurveyQuotaCard(BuildContext context, Survey survey) {
    // Calculate total progress for the survey
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

    double percent = totalTarget > 0 ? totalProgress / totalTarget : 0.0;

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
        ],
      ),
    );
  }
}
