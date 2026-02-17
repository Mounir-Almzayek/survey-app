import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/styles/app_colors.dart';
import '../../../../../core/utils/responsive_layout.dart';
import '../../../../../core/models/survey/researcher_quota_model.dart';
import '../../../../../core/models/survey/survey_model.dart';

class SurveyAnalysisCard extends StatelessWidget {
  final Survey survey;

  const SurveyAnalysisCard({super.key, required this.survey});

  @override
  Widget build(BuildContext context) {
    final quotas = survey.assignments?.first.researcherQuotas ?? [];
    final s = S.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: AppColors.primary,
                  size: context.adaptiveIcon(20.sp),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  survey.title ?? '',
                  style: TextStyle(
                    fontSize: context.adaptiveFont(16.sp),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: quotas.isNotEmpty
                ? ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: quotas.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      return _buildCategoryItem(context, quotas[index], s);
                    },
                  )
                : Center(
                    child: Text(
                      s.no_data,
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, ResearcherQuota quota, S s) {
    final progresspercent = quota.completionPercentage / 100;
    final progressColor = AppColors.primary.withOpacity(
      quota.progressDisplayAlpha,
    );

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50.r,
            height: 50.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progresspercent.clamp(0.0, 1.0),
                  strokeWidth: 5.r,
                  backgroundColor: AppColors.muted.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '${(progresspercent * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: context.adaptiveFont(12.sp),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quota.localizedDemographicDescription(s),
                  style: TextStyle(
                    fontSize: context.adaptiveFont(14.sp),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 14.sp,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${quota.progress} / ${quota.target}',
                      style: TextStyle(
                        fontSize: context.adaptiveFont(12.sp),
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
