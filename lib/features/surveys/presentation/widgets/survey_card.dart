import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/styles/app_colors.dart';
import '../../models/survey.dart';
import '../../models/survey_status.dart';

class SurveyCard extends StatelessWidget {
  final Survey survey;
  final VoidCallback onTap;
  final int index; // For staggered animation delay

  const SurveyCard({
    super.key,
    required this.survey,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status color and text
    final statusColor = _getStatusColor(survey.status);
    final statusText = survey.status.name.toUpperCase(); // Or localized

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Interval(
        (index * 0.1).clamp(0.0, 1.0),
        1.0,
        curve: Curves.easeOutQuart,
      ),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: AppColors.border.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with Status Strip
                Container(
                  height: 6.h,
                  width: double.infinity,
                  color: statusColor,
                ),
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              survey.title,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        survey.description,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.secondaryText,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          _buildMetaData(
                            Icons.calendar_today_rounded,
                            _formatDate(survey.availabilityEndAt),
                            "Due Date",
                          ),
                          Spacer(),
                          _buildMetaData(
                            Icons.question_answer_rounded,
                            "${survey.maxResponses}", // Often used as target responses
                            "Target Responses",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaData(IconData icon, String text, String label) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.muted),
        SizedBox(width: 6.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(SurveyStatus status) {
    switch (status) {
      case SurveyStatus.published:
        return Colors.green;
      case SurveyStatus.draft:
        return Colors.orange;
      case SurveyStatus.archived:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "No Deadline";
    return "${date.day}/${date.month}/${date.year}";
  }
}
