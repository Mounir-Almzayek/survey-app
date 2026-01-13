import 'package:flutter/material.dart';
import '../../models/survey/question_model.dart';
import '../../styles/app_colors.dart';
import '../custom_radio_group_field.dart';
import 'survey_question_card.dart';

class SurveyRadioField extends StatelessWidget {
  final Question question;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final bool isVisible;

  const SurveyRadioField({
    super.key,
    required this.question,
    required this.onChanged,
    this.selectedValue,
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
      child: CustomRadioGroupField<String>(
        label: "", // Label handled by SurveyQuestionCard
        activeColor: AppColors.surveyPrimary,
        items:
            question.questionOptions?.map((e) => e.value ?? "").toList() ?? [],
        getLabel: (val) =>
            question.questionOptions
                ?.firstWhere(
                  (e) => e.value == val,
                  orElse: () => question.questionOptions!.first,
                )
                .label ??
            val,
        selectedValue: selectedValue,
        onChanged: onChanged,
      ),
    );
  }
}
