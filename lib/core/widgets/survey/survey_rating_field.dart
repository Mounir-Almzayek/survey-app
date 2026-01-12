import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/survey/question_model.dart';
import '../../styles/app_colors.dart';
import 'survey_question_card.dart';

class SurveyRatingField extends StatelessWidget {
  final Question question;
  final int? value;
  final ValueChanged<int> onChanged;
  final String? errorText;
  final bool isVisible;
  final int maxRating;

  const SurveyRatingField({
    super.key,
    required this.question,
    required this.onChanged,
    this.value,
    this.errorText,
    this.isVisible = true,
    this.maxRating = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SurveyQuestionCard(
      label: question.label,
      helpText: question.helpText,
      isRequired: question.isRequired,
      errorText: errorText,
      isVisible: isVisible,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(maxRating, (index) {
          final starValue = index + 1;
          final isSelected = value != null && starValue <= value!;
          return GestureDetector(
            onTap: () => onChanged(starValue),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Icon(
                isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                color: isSelected ? Colors.amber : AppColors.mutedForeground,
                size: 40.sp,
              ),
            ),
          );
        }),
      ),
    );
  }
}
