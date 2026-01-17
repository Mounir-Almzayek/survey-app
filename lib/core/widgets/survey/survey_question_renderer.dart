import 'package:flutter/material.dart';
import '../../models/survey/question_model.dart';
import '../../enums/survey_enums.dart';
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

class SurveyQuestionRenderer extends StatelessWidget {
  final Question question;
  final dynamic value;
  final ValueChanged<dynamic> onAnswerChange;
  final String? errorText;
  final bool isVisible;
  final bool isEditable;

  const SurveyQuestionRenderer({
    super.key,
    required this.question,
    required this.value,
    required this.onAnswerChange,
    this.errorText,
    this.isVisible = true,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || question.type == null) return const SizedBox.shrink();

    switch (question.type!) {
      case QuestionType.textShort:
        return SurveyTextField(
          question: question,
          value: value as String?,
          onChanged: (val) => onAnswerChange(val),
          errorText: errorText,
          isVisible: isVisible,
          isEditable: isEditable,
        );
      case QuestionType.textLong:
        return SurveyTextField(
          question: question,
          value: value as String?,
          onChanged: (val) => onAnswerChange(val),
          errorText: errorText,
          isVisible: isVisible,
          isLongText: true,
          isEditable: isEditable,
        );
      case QuestionType.number:
        return SurveyNumberField(
          question: question,
          value: value?.toString(),
          onChanged: (val) => onAnswerChange(num.tryParse(val)),
          errorText: errorText,
          isVisible: isVisible,
          isEditable: isEditable,
        );
      case QuestionType.radio:
        return SurveyRadioField(
          question: question,
          selectedValue: value as String?,
          onChanged: (val) => onAnswerChange(val),
          errorText: errorText,
          isVisible: isVisible,
          isEditable: isEditable,
        );
      case QuestionType.checkbox:
        return SurveyCheckboxField(
          question: question,
          selectedValues: value is List ? List<String>.from(value) : [],
          onChanged: (val) => onAnswerChange(val),
          errorText: errorText,
          isVisible: isVisible,
          isEditable: isEditable,
        );
      case QuestionType.dropdown:
        return SurveyDropdownField(
          question: question,
          selectedValue: value as String?,
          onChanged: (val) => onAnswerChange(val),
          errorText: errorText,
          isVisible: isVisible,
          isEditable: isEditable,
        );
      case QuestionType.date:
      case QuestionType.time:
      case QuestionType.datetime:
        return SurveyDateField(
          question: question,
          value: value as String?,
          onChanged: (val) => onAnswerChange(val),
          errorText: errorText,
          isVisible: isVisible,
          isEditable: isEditable,
        );
      case QuestionType.file:
        return SurveyFileField(
          question: question,
          onChanged: (val) => onAnswerChange(val),
          errorText: errorText,
          isVisible: isVisible,
          isEditable: isEditable,
        );
      case QuestionType.rating:
        return SurveyRatingField(
          question: question,
          value: value is int
              ? value
              : (value != null ? int.tryParse(value.toString()) : null),
          onChanged: (val) => onAnswerChange(val),
          errorText: errorText,
          isVisible: isVisible,
          isEditable: isEditable,
        );
      case QuestionType.slider:
        return SurveySliderField(
          question: question,
          value: value is num
              ? (value as num).toDouble()
              : (value != null ? double.tryParse(value.toString()) : null),
          onChanged: (val) => onAnswerChange(val),
          errorText: errorText,
          isVisible: isVisible,
          isEditable: isEditable,
        );
      case QuestionType.gps:
        return SurveyGpsField(
          question: question,
          onChanged: (val) => onAnswerChange(val),
          errorText: errorText,
          isVisible: isVisible,
          isEditable: isEditable,
        );
      case QuestionType.singleSelectGrid:
      case QuestionType.multiSelectGrid:
        return SurveyGridField(
          question: question,
          onChanged: (val) => onAnswerChange(val),
          errorText: errorText,
          isVisible: isVisible,
          isEditable: isEditable,
        );
    }
  }
}
