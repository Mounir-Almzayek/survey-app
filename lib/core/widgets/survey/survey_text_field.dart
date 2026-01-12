import 'package:flutter/material.dart';
import '../../models/survey/question_model.dart';
import '../custom_text_field.dart';
import 'survey_question_card.dart';

class SurveyTextField extends StatefulWidget {
  final Question question;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isLongText;

  const SurveyTextField({
    super.key,
    required this.question,
    this.value,
    this.onChanged,
    this.errorText,
    this.isVisible = true,
    this.isLongText = false,
  });

  @override
  State<SurveyTextField> createState() => _SurveyTextFieldState();
}

class _SurveyTextFieldState extends State<SurveyTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(SurveyTextField oldWidget) {
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
      child: CustomTextField(
        controller: _controller,
        label: null,
        hintText: widget.question.helpText,
        onChanged: widget.onChanged,
        keyboardType: widget.isLongText
            ? TextInputType.multiline
            : TextInputType.text,
      ),
    );
  }
}
