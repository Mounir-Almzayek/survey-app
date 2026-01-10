import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../styles/app_colors.dart';

class SurveyQuestionCard extends StatelessWidget {
  final String label;
  final String? helpText;
  final bool isRequired;
  final Widget child;
  final String? errorText;
  final bool isVisible;

  const SurveyQuestionCard({
    super.key,
    required this.label,
    this.helpText,
    this.isRequired = false,
    required this.child,
    this.errorText,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: errorText != null
              ? AppColors.destructive
              : AppColors.border.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label + (isRequired ? ' *' : ''),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
          if (helpText != null && helpText!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              helpText!,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.mutedForeground,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          SizedBox(height: 16.h),
          child,
          if (errorText != null) ...[
            SizedBox(height: 8.h),
            Text(
              errorText!,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.destructive,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
