import 'package:flutter/material.dart';
import '../../models/survey/question_model.dart';
import '../custom_text_field.dart';
import 'survey_question_card.dart';

class SurveyTextField extends StatelessWidget {
  final Question question;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isLongText;

  const SurveyTextField({
    super.key,
    required this.question,
    required this.controller,
    this.onChanged,
    this.errorText,
    this.isVisible = true,
    this.isLongText = false,
  });

  @override
  Widget build(BuildContext context) {
    return SurveyQuestionCard(
      label: question.label,
      helpText: question.helpText,
      isRequired: question.isRequired,
      errorText: errorText,
      isVisible: isVisible,
      child: CustomTextField(
        controller: controller,
        label: null, // Label handled by SurveyQuestionCard
        hintText: question.helpText,
        onChanged: onChanged,
        keyboardType: isLongText ? TextInputType.multiline : TextInputType.text,
      ),
    );
  }
}
