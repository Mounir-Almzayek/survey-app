import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../models/public_link_active_response.dart';

class ActiveResponsesStats extends StatelessWidget {
  final List<PublicLinkActiveResponse> responses;

  const ActiveResponsesStats({super.key, required this.responses});

  @override
  Widget build(BuildContext context) {
    if (responses.isEmpty) return const SizedBox.shrink();
    final s = S.of(context);

    // Calculate overall average progress
    final totalProgress = responses.fold<double>(
      0,
      (sum, r) => sum + (r.lastSectionId / r.totalSections),
    );
    final avgProgress = totalProgress / responses.length;

    return Container(
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          // Circular Progress Indicator (The "Chart")
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 70.r,
                width: 70.r,
                child: CircularProgressIndicator(
                  value: avgProgress,
                  strokeWidth: 8.r,
                  backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.warning,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${(avgProgress * 100).toInt()}%",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  Text(
                    s.avg,
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: 20.w),
          // Statistics Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatItem(
                  label: s.in_progress_surveys,
                  value: responses.length.toString(),
                  color: AppColors.warning,
                ),
                SizedBox(height: 8.h),
                _StatItem(
                  label: s.total_sections_touched,
                  value: responses
                      .fold<int>(0, (sum, r) => sum + r.lastSectionId)
                      .toString(),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }
}
