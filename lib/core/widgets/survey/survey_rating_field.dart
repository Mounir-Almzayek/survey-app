import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/survey/question_model.dart';
import '../../styles/app_colors.dart';
import '../../utils/responsive_layout.dart';
import 'survey_question_card.dart';

class SurveyRatingField extends StatelessWidget {
  final Question question;
  final int? value;
  final ValueChanged<int> onChanged;
  final String? errorText;
  final bool isVisible;
  final int maxRating;
  final bool isEditable;

  const SurveyRatingField({
    super.key,
    required this.question,
    required this.onChanged,
    this.value,
    this.errorText,
    this.isVisible = true,
    this.maxRating = 5,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(maxRating, (index) {
          final starValue = index + 1;
          final isSelected = value != null && starValue <= value!;
          return GestureDetector(
            onTap: isEditable ? () => onChanged(starValue) : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Icon(
                isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                color: isSelected ? Colors.amber : AppColors.mutedForeground,
                size: context.adaptiveIcon(32.sp),
              ),
            ),
          );
        }),
      ),
    );
  }
}
