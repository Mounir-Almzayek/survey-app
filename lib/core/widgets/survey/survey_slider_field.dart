import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/survey/question_model.dart';
import '../../styles/app_colors.dart';
import '../../utils/responsive_layout.dart';
import 'survey_question_card.dart';

class SurveySliderField extends StatelessWidget {
  final Question question;
  final double? value;
  final ValueChanged<double> onChanged;
  final String? errorText;
  final bool isVisible;
  final double min;
  final double max;
  final int? divisions;
  final bool isEditable;

  const SurveySliderField({
    super.key,
    required this.question,
    required this.onChanged,
    this.value,
    this.errorText,
    this.isVisible = true,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveValue = value ?? min;

    return SurveyQuestionCard(
      label: question.label,
      helpText: question.helpText,
      isRequired: question.isRequired,
      errorText: errorText,
      isVisible: isVisible,
      validations: question.questionValidations,
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.surveyPrimary,
              inactiveTrackColor: AppColors.muted,
              thumbColor: AppColors.surveyPrimary,
              overlayColor: AppColors.surveyPrimary.withAlpha(32),
              valueIndicatorColor: AppColors.surveyPrimary,
              valueIndicatorTextStyle: const TextStyle(color: Colors.white),
            ),
            child: Slider(
              value: effectiveValue,
              min: min,
              max: max,
              divisions: divisions,
              label: effectiveValue.round().toString(),
              onChanged: isEditable ? onChanged : null,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  min.round().toString(),
                  style: TextStyle(
                    fontSize: context.adaptiveFont(11.sp),
                    color: AppColors.mutedForeground,
                  ),
                ),
                Text(
                  max.round().toString(),
                  style: TextStyle(
                    fontSize: context.adaptiveFont(11.sp),
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
