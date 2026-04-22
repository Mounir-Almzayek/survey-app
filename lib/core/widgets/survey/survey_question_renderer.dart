import 'package:flutter/material.dart';
import '../../models/survey/question_model.dart';
import '../../enums/survey_enums.dart';
import '../../validation/live_validation_controller.dart';
import '../../validation/rule_registry.dart';
import 'survey_text_field.dart';
import 'survey_radio_field.dart';
import 'survey_checkbox_field.dart';
import 'survey_dropdown_field.dart';
import 'survey_number_field.dart';
import 'survey_date_field.dart';
import 'survey_file_field.dart';
import 'survey_rating_field.dart';
import 'survey_slider_field.dart';
import 'survey_gps_field.dart';
import 'survey_grid_field.dart';
import 'survey_phone_field.dart';

class SurveyQuestionRenderer extends StatefulWidget {
  final Question question;
  final dynamic value;
  final ValueChanged<dynamic> onAnswerChange;
  final String? errorText;
  final bool isVisible;
  final bool isEditable;

  /// Monotonic counter from the bloc — every time it changes, the renderer
  /// flips its live-validation controllers into "submit attempted" mode so
  /// previously-cached errors render without the user re-touching the field.
  final int submitAttemptCount;

  const SurveyQuestionRenderer({
    super.key,
    required this.question,
    required this.value,
    required this.onAnswerChange,
    this.errorText,
    this.isVisible = true,
    this.isEditable = true,
    this.submitAttemptCount = 0,
  });

  @override
  State<SurveyQuestionRenderer> createState() => _SurveyQuestionRendererState();
}

class _SurveyQuestionRendererState extends State<SurveyQuestionRenderer> {
  final Map<int, LiveValidationController> _controllers = {};
  int _lastSubmitAttempt = 0;

  LiveValidationController _controllerFor(Question q) =>
      _controllers.putIfAbsent(
        q.id,
        () => LiveValidationController(
          question: q,
          locale: Localizations.localeOf(context).languageCode,
        ),
      );

  @override
  void didUpdateWidget(SurveyQuestionRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.submitAttemptCount != _lastSubmitAttempt) {
      _lastSubmitAttempt = widget.submitAttemptCount;
      for (final c in _controllers.values) {
        c.markSubmitAttempted();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    if (!widget.isVisible || q.type == null) return const SizedBox.shrink();

    switch (q.type!) {
      case QuestionType.textShort:
        return SurveyTextField(
          question: q,
          value: widget.value as String?,
          onChanged: (val) => widget.onAnswerChange(val),
          errorText: widget.errorText,
          isVisible: widget.isVisible,
          isEditable: widget.isEditable,
          inputFormatters: RuleRegistry.formattersFor(q),
          validationController: _controllerFor(q),
        );
      case QuestionType.textLong:
        return SurveyTextField(
          question: q,
          value: widget.value as String?,
          onChanged: (val) => widget.onAnswerChange(val),
          errorText: widget.errorText,
          isVisible: widget.isVisible,
          isLongText: true,
          isEditable: widget.isEditable,
          inputFormatters: RuleRegistry.formattersFor(q),
          validationController: _controllerFor(q),
        );
      case QuestionType.number:
        return SurveyNumberField(
          question: q,
          value: widget.value?.toString(),
          onChanged: (val) => widget.onAnswerChange(num.tryParse(val)),
          errorText: widget.errorText,
          isVisible: widget.isVisible,
          isEditable: widget.isEditable,
          inputFormatters: RuleRegistry.formattersFor(q),
          validationController: _controllerFor(q),
        );
      case QuestionType.radio:
        return SurveyRadioField(
          question: q,
          selectedValue: widget.value as String?,
          onChanged: (val) => widget.onAnswerChange(val),
          errorText: widget.errorText,
          isVisible: widget.isVisible,
          isEditable: widget.isEditable,
        );
      case QuestionType.checkbox:
        return SurveyCheckboxField(
          question: q,
          selectedValues:
              widget.value is List ? List<String>.from(widget.value) : [],
          onChanged: (val) => widget.onAnswerChange(val),
          errorText: widget.errorText,
          isVisible: widget.isVisible,
          isEditable: widget.isEditable,
        );
      case QuestionType.dropdown:
        return SurveyDropdownField(
          question: q,
          selectedValue: widget.value as String?,
          onChanged: (val) => widget.onAnswerChange(val),
          errorText: widget.errorText,
          isVisible: widget.isVisible,
          isEditable: widget.isEditable,
        );
      case QuestionType.date:
      case QuestionType.time:
      case QuestionType.datetime:
        return SurveyDateField(
          question: q,
          value: widget.value as String?,
          onChanged: (val) => widget.onAnswerChange(val),
          errorText: widget.errorText,
          isVisible: widget.isVisible,
          isEditable: widget.isEditable,
        );
      case QuestionType.file:
        return SurveyFileField(
          question: q,
          value: widget.value as String?,
          onChanged: (val) => widget.onAnswerChange(val),
          errorText: widget.errorText,
          isVisible: widget.isVisible,
          isEditable: widget.isEditable,
        );
      case QuestionType.rating:
        return SurveyRatingField(
          question: q,
          value: widget.value is int
              ? widget.value
              : (widget.value != null
                  ? int.tryParse(widget.value.toString())
                  : null),
          onChanged: (val) => widget.onAnswerChange(val),
          errorText: widget.errorText,
          isVisible: widget.isVisible,
          isEditable: widget.isEditable,
        );
      case QuestionType.slider:
        return SurveySliderField(
          question: q,
          value: widget.value is num
              ? (widget.value as num).toDouble()
              : (widget.value != null
                  ? double.tryParse(widget.value.toString())
                  : null),
          onChanged: (val) => widget.onAnswerChange(val),
          errorText: widget.errorText,
          isVisible: widget.isVisible,
          isEditable: widget.isEditable,
        );
      case QuestionType.gps:
        return SurveyGpsField(
          question: q,
          value: widget.value is Map ? widget.value : null,
          onChanged: (val) => widget.onAnswerChange(val),
          errorText: widget.errorText,
          isVisible: widget.isVisible,
          isEditable: widget.isEditable,
        );
      case QuestionType.singleSelectGrid:
      case QuestionType.multiSelectGrid:
        return SurveyGridField(
          question: q,
          value: widget.value is Map ? widget.value : null,
          onChanged: (val) => widget.onAnswerChange(val),
          errorText: widget.errorText,
          isVisible: widget.isVisible,
          isEditable: widget.isEditable,
        );
      case QuestionType.phoneNumber:
        return SurveyPhoneField(
          question: q,
          value: widget.value as String?,
          onChanged: (val) => widget.onAnswerChange(val),
          errorText: widget.errorText,
          isVisible: widget.isVisible,
          isEditable: widget.isEditable,
        );
    }
  }
}
