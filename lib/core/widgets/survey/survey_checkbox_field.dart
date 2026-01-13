import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/survey/question_model.dart';
import '../../styles/app_colors.dart';
import 'survey_question_card.dart';

class SurveyCheckboxField extends StatelessWidget {
  final Question question;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;
  final String? errorText;
  final bool isVisible;

  const SurveyCheckboxField({
    super.key,
    required this.question,
    required this.onChanged,
    this.selectedValues = const [],
    this.errorText,
    this.isVisible = true,
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
        children:
            question.questionOptions?.map((option) {
              final isSelected = selectedValues.contains(option.value);
              return GestureDetector(
                onTap: () {
                  final newValues = List<String>.from(selectedValues);
                  if (isSelected) {
                    newValues.remove(option.value);
                  } else if (option.value != null) {
                    newValues.add(option.value!);
                  }
                  onChanged(newValues);
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.surveyPrimary
                          : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                    color: isSelected
                        ? AppColors.surveyPrimary.withOpacity(0.05)
                        : AppColors.background.withOpacity(0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: isSelected
                            ? AppColors.surveyPrimary
                            : AppColors.mutedForeground,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          option.label ?? "",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isSelected
                                ? AppColors.surveyPrimary
                                : AppColors.primaryText,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList() ??
            [],
      ),
    );
  }
}
