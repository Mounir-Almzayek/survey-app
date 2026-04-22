import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/survey/question_model.dart';
import '../../validation/live_validation_controller.dart';
import '../custom_text_field.dart';
import 'survey_question_card.dart';

class SurveyNumberField extends StatefulWidget {
  final Question question;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isEditable;
  final List<TextInputFormatter>? inputFormatters;
  final LiveValidationController? validationController;

  const SurveyNumberField({
    super.key,
    required this.question,
    this.value,
    this.onChanged,
    this.errorText,
    this.isVisible = true,
    this.isEditable = true,
    this.inputFormatters,
    this.validationController,
  });

  @override
  State<SurveyNumberField> createState() => _SurveyNumberFieldState();
}

class _SurveyNumberFieldState extends State<SurveyNumberField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      widget.validationController?.onBlur(_controller.text);
    }
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
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String v) {
    widget.onChanged?.call(v);
    widget.validationController?.onChanged(v);
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
      liveController: widget.validationController,
      child: Focus(
        focusNode: _focusNode,
        child: CustomTextField(
          controller: _controller,
          label: null,
          hintText: widget.question.helpText,
          onChanged: widget.isEditable ? _handleChanged : null,
          enabled: widget.isEditable,
          inputFormatters: widget.inputFormatters,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
        ),
      ),
    );
  }
}
