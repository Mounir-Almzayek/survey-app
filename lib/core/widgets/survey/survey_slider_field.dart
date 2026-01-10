import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/survey/question_model.dart';
import '../../styles/app_colors.dart';
import 'survey_question_card.dart';

class SurveySliderField extends StatelessWidget {
  final Question question;
  final double value;
  final ValueChanged<double> onChanged;
  final String? errorText;
  final bool isVisible;
  final double min;
  final double max;
  final int? divisions;

  const SurveySliderField({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.isVisible = true,
    this.min = 0,
    this.max = 100,
    this.divisions,
  });

  @override
  Widget build(BuildContext context) {
    return SurveyQuestionCard(
      label: question.label,
      helpText: question.helpText,
      isRequired: question.isRequired,
      errorText: errorText,
      isVisible: isVisible,
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.muted,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withAlpha(32),
              valueIndicatorColor: AppColors.primary,
              valueIndicatorTextStyle: const TextStyle(color: Colors.white),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: value.round().toString(),
              onChanged: onChanged,
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
                    fontSize: 12.sp,
                    color: AppColors.mutedForeground,
                  ),
                ),
                Text(
                  max.round().toString(),
                  style: TextStyle(
                    fontSize: 12.sp,
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
