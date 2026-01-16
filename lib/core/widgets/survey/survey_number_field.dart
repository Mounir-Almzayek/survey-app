import 'package:flutter/material.dart';
import '../../models/survey/question_model.dart';
import '../custom_text_field.dart';
import 'survey_question_card.dart';

class SurveyNumberField extends StatefulWidget {
  final Question question;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isEditable;

  const SurveyNumberField({
    super.key,
    required this.question,
    this.value,
    this.onChanged,
    this.errorText,
    this.isVisible = true,
    this.isEditable = true,
  });

  @override
  State<SurveyNumberField> createState() => _SurveyNumberFieldState();
}

class _SurveyNumberFieldState extends State<SurveyNumberField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(SurveyNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SurveyQuestionCard(
      label: widget.question.label,
      helpText: widget.question.helpText,
      isRequired: widget.question.isRequired,
      errorText: widget.errorText,
      isVisible: widget.isVisible,
      validations: widget.question.questionValidations,
      child: CustomTextField(
        controller: _controller,
        label: null,
        hintText: widget.question.helpText,
        onChanged: widget.isEditable ? widget.onChanged : null,
        enabled: widget.isEditable,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
      ),
    );
  }
}
