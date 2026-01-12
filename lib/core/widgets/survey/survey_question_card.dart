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
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: errorText != null
              ? AppColors.destructive
              : AppColors.border.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
                fontFamily: 'Cairo', // Use app font
              ),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppColors.destructive,
                      fontSize: 15.sp,
                    ),
                  ),
              ],
            ),
          ),
          if (helpText != null && helpText!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              helpText!,
              style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
            ),
          ],
          SizedBox(height: 12.h),
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
