import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../styles/app_colors.dart';
import '../../models/survey/question_validation_model.dart';
import '../../utils/responsive_layout.dart';

class SurveyQuestionCard extends StatelessWidget {
  final String? label;
  final String? helpText;
  final bool? isRequired;
  final Widget child;
  final String? errorText;
  final bool isVisible;
  final List<QuestionValidation>? validations;

  const SurveyQuestionCard({
    super.key,
    this.label,
    this.helpText,
    this.isRequired = false,
    required this.child,
    this.errorText,
    this.isVisible = true,
    this.validations,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 8.h,
        horizontal: context.responsive(16.w, tablet: 20.w, desktop: 24.w),
      ),
      padding: EdgeInsets.all(
        context.responsive(16.r, tablet: 20.r, desktop: 24.r),
      ),
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
                fontSize: context.adaptiveFont(14.sp),
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
                fontFamily: 'Cairo', // Use app font
              ),
              children: [
                if (isRequired != null && isRequired!)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppColors.destructive,
                      fontSize: context.adaptiveFont(14.sp),
                    ),
                  ),
              ],
            ),
          ),
          if (helpText != null && helpText!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              helpText!,
              style: TextStyle(
                fontSize: context.adaptiveFont(11.sp),
                color: AppColors.secondaryText,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          child,
          if (validations != null && validations!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: validations!.map((qv) {
                final validation = qv.validation;
                if (validation == null || validation.isActive == false) {
                  return const SizedBox.shrink();
                }

                final title = locale == 'ar'
                    ? validation.arTitle
                    : validation.enTitle;
                if (title == null) return const SizedBox.shrink();

                final values = qv.values;
                String displayText = title;

                if (values != null && values.isNotEmpty) {
                  final min = values['min'];
                  final max = values['max'];
                  if (min != null && max != null) {
                    displayText = '$title: $min – $max';
                  } else if (min != null) {
                    displayText = '$title: $min+';
                  } else if (max != null) {
                    displayText = '$title: ≤$max';
                  }
                }

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: context.adaptiveFont(10.sp),
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (errorText != null) ...[
            SizedBox(height: 8.h),
            Text(
              errorText!,
              style: TextStyle(
                fontSize: context.adaptiveFont(11.sp),
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
