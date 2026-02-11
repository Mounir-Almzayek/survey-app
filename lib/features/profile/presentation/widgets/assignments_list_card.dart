import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/enums/survey_enums.dart';
import '../../models/researcher_profile_response_model.dart';

class AssignmentsListCard extends StatelessWidget {
  final List<ResearcherAssignmentModel> assignments;

  const AssignmentsListCard({super.key, required this.assignments});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                Icon(
                  Icons.assignment_turned_in_rounded,
                  color: AppColors.primary,
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  locale.assignments,
                  style: TextStyle(
                    fontSize: context.adaptiveFont(16.sp),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
          if (assignments.isEmpty) ...[
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Text(
                  locale.noAssignments,
                  style: TextStyle(
                    fontSize: context.adaptiveFont(14.sp),
                    color: AppColors.secondaryText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.r),
              itemCount: assignments.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: AppColors.border.withValues(alpha: 0.3),
              ),
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                return _buildAssignmentItem(context, assignment, locale);
              },
            ),
            SizedBox(height: 20.h),
          ],
        ],
      ),
    );
  }

  Widget _buildAssignmentItem(
    BuildContext context,
    ResearcherAssignmentModel assignment,
    S locale,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  assignment.surveyTitle,
                  style: TextStyle(
                    fontSize: context.adaptiveFont(16.sp),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              _buildStatusChip(context, assignment.status),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                assignment.type == AssignmentType.bounded
                    ? Icons.devices_other_rounded
                    : Icons.phone_android_rounded,
                color: AppColors.secondaryText,
                size: 16.r,
              ),
              SizedBox(width: 8.w),
              Text(
                assignment.type == AssignmentType.bounded
                    ? locale.boundedDevice
                    : locale.unboundedDevice,
                style: TextStyle(
                  fontSize: context.adaptiveFont(14.sp),
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          if (assignment.quotas.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _buildQuotasSummary(context, assignment.quotas, locale),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, AssignmentStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case AssignmentStatus.pending:
        backgroundColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
        break;
      case AssignmentStatus.inProgress:
        backgroundColor = AppColors.primary.withValues(alpha: 0.1);
        textColor = AppColors.primary;
        break;
      case AssignmentStatus.completed:
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        break;
      case AssignmentStatus.revoked:
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        status.toString().split('.').last.toUpperCase(),
        style: TextStyle(
          fontSize: context.adaptiveFont(12.sp),
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildQuotasSummary(
    BuildContext context,
    List<ResearcherQuotaModel> quotas,
    S locale,
  ) {
    final totalTarget = quotas.fold<int>(0, (sum, quota) => sum + quota.target);
    final totalCollected = quotas.fold<int>(
      0,
      (sum, quota) => sum + quota.collected,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.progress,
                  style: TextStyle(
                    fontSize: context.adaptiveFont(12.sp),
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$totalCollected / $totalTarget',
                  style: TextStyle(
                    fontSize: context.adaptiveFont(14.sp),
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          CircularProgressIndicator(
            value: totalTarget > 0 ? totalCollected / totalTarget : 0,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 4.r,
          ),
        ],
      ),
    );
  }
}
