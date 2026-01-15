import 'package:flutter/material.dart';
import '../../models/survey/question_model.dart';
import '../../enums/survey_enums.dart';
import '../custom_date_picker_field.dart';
import 'survey_question_card.dart';

class SurveyDateField extends StatelessWidget {
  final Question question;
  final String? value;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool isVisible;

  const SurveyDateField({
    super.key,
    required this.question,
    required this.onChanged,
    this.value,
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
      validations: question.questionValidations,
      child: CustomDatePickerField(
        label: "", // Handled by SurveyQuestionCard
        selectedDate: value,
        onDateSelected: onChanged,
        pickTime: question.type == QuestionType.datetime ||
            question.type == QuestionType.time,
      ),
    );
  }
}
