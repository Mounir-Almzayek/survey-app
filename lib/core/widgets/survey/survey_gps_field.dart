import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/survey/question_model.dart';
import '../../styles/app_colors.dart';
import 'survey_question_card.dart';

class SurveyGPSField extends StatelessWidget {
  final Question question;
  final String? coordinates; // "lat,lng"
  final VoidCallback onFetchLocation;
  final String? errorText;
  final bool isVisible;
  final bool isFetching;

  const SurveyGPSField({
    super.key,
    required this.question,
    required this.onFetchLocation,
    this.coordinates,
    this.errorText,
    this.isVisible = true,
    this.isFetching = false,
  });

  @override
  Widget build(BuildContext context) {
    return SurveyQuestionCard(
      label: question.label,
      helpText: question.helpText,
      isRequired: question.isRequired,
      errorText: errorText,
      isVisible: isVisible,
      child: Container(
        padding: EdgeInsets.all(12.r),
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
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coordinates?.isNotEmpty == true
                        ? coordinates!
                        : "Location not set",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: coordinates?.isNotEmpty == true
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
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            else
              TextButton(
                onPressed: onFetchLocation,
                child: Text(
                  coordinates?.isNotEmpty == true ? "Refresh" : "Fetch",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
