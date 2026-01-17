import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/survey/question_model.dart';
import '../../styles/app_colors.dart';
import '../../utils/responsive_layout.dart';
import 'survey_question_card.dart';

class SurveyGpsField extends StatelessWidget {
  final Question question;
  final String? value; // "lat,lng"
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isFetching;
  final bool isEditable;

  const SurveyGpsField({
    super.key,
    required this.question,
    required this.onChanged,
    this.value,
    this.errorText,
    this.isVisible = true,
    this.isFetching = false,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    return SurveyQuestionCard(
      label: question.label,
      helpText: question.helpText,
      isRequired: question.isRequired,
      errorText: errorText,
      isVisible: isVisible,
      validations: question.questionValidations,
      child: Container(
        padding: context.responsive(
          EdgeInsets.all(10.r),
          tablet: EdgeInsets.all(12.r),
          desktop: EdgeInsets.all(14.r),
        ),
        decoration: BoxDecoration(
          color: AppColors.muted.withOpacity(0.3),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: const BoxDecoration(
                color: AppColors.surveyPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: context.adaptiveIcon(18.sp),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value?.isNotEmpty == true ? value! : "Location not set",
                    style: TextStyle(
                      fontSize: context.adaptiveFont(13.sp),
                      fontWeight: FontWeight.w600,
                      color: value?.isNotEmpty == true
                          ? AppColors.primaryText
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            if (isFetching)
              SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.surveyPrimary,
                  ),
                ),
              )
            else if (isEditable)
              TextButton(
                onPressed: () {
                  // In a real scenario, this would trigger geolocator
                  // For now, it's a placeholder for the UI
                },
                child: Text(
                  value?.isNotEmpty == true ? "Refresh" : "Fetch",
                  style: TextStyle(
                    fontSize: context.adaptiveFont(12.sp),
                    fontWeight: FontWeight.bold,
                    color: AppColors.surveyPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
