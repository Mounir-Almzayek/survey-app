import 'package:flutter/material.dart';
import '../../models/survey/question_model.dart';
import '../../enums/survey_enums.dart';
import '../custom_date_picker_field.dart';
import 'survey_question_card.dart';

class SurveyDateField extends StatelessWidget {
  final Question question;
  final String? selectedDate;
  final ValueChanged<String> onDateSelected;
  final String? errorText;
  final bool isVisible;

  const SurveyDateField({
    super.key,
    required this.question,
    required this.onDateSelected,
    this.selectedDate,
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
      child: CustomDatePickerField(
        label: "", // Handled by SurveyQuestionCard
        selectedDate: selectedDate,
        onDateSelected: onDateSelected,
        pickTime:
            question.type == QuestionType.datetime ||
            question.type == QuestionType.time,
      ),
    );
  }
}
