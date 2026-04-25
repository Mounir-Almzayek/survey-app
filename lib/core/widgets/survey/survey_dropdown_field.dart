import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/generated/l10n.dart';
import '../../models/survey/question_model.dart';
import '../../models/survey/question_option_model.dart';
import '../../styles/app_colors.dart';
import '../custom_dropdown_field.dart';
import '../custom_text_field.dart';
import 'other_option_value.dart';
import 'survey_question_card.dart';

class SurveyDropdownField extends StatefulWidget {
  final Question question;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isEditable;

  const SurveyDropdownField({
    super.key,
    required this.question,
    required this.onChanged,
    this.selectedValue,
    this.errorText,
    this.isVisible = true,
    this.isEditable = true,
  });

  @override
  State<SurveyDropdownField> createState() => _SurveyDropdownFieldState();
}

class _SurveyDropdownFieldState extends State<SurveyDropdownField> {
  late final TextEditingController _otherController;

  @override
  void initState() {
    super.initState();
    _otherController = TextEditingController(text: _initialOtherText());
  }

  String _initialOtherText() {
    final v = widget.selectedValue;
    if (v == null) return '';
    return OtherOptionValue.isOtherRadioValue(v, widget.question.questionOptions)
        ? v
        : '';
  }

  @override
  void didUpdateWidget(SurveyDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue == oldWidget.selectedValue) return;
    final isOther = OtherOptionValue.isOtherRadioValue(
      widget.selectedValue,
      widget.question.questionOptions,
    );
    final desired = isOther ? widget.selectedValue ?? '' : '';
    if (_otherController.text != desired) {
      _otherController.text = desired;
    }
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  QuestionOption? get _otherOption {
    final opts = widget.question.questionOptions;
    if (opts == null) return null;
    for (final o in opts) {
      if (o.isOther) return o;
    }
    return null;
  }

  String? get _highlightedOptionValue {
    final v = widget.selectedValue;
    if (v == null || v.isEmpty) return null;
    final opts = widget.question.questionOptions ?? const <QuestionOption>[];
    if (opts.any((o) => o.value == v)) return v;
    return _otherOption?.value;
  }

  bool get _isOtherSelected {
    final v = widget.selectedValue;
    if (v == null || v.isEmpty) return false;
    final other = _otherOption;
    if (other != null && other.value == v) return true;
    return OtherOptionValue.isOtherRadioValue(
      v,
      widget.question.questionOptions,
    );
  }

  void _onDropdownChanged(String? selectedOptionValue) {
    if (!widget.isEditable) return;
    final other = _otherOption;
    if (other != null && selectedOptionValue == other.value) {
      final txt = _otherController.text.trim();
      widget.onChanged(txt.isEmpty ? other.value : txt);
      return;
    }
    widget.onChanged(selectedOptionValue);
  }

  void _onOtherTextChanged(String text) {
    if (!widget.isEditable) return;
    final trimmed = text.trim();
    final other = _otherOption;
    widget.onChanged(trimmed.isEmpty ? other?.value : trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.question.questionOptions ?? const <QuestionOption>[];
    final hasOther = OtherOptionValue.hasOtherOption(options);

    return SurveyQuestionCard(
      label: widget.question.label,
      helpText: widget.question.helpText,
      isRequired: widget.question.isRequired,
      errorText: widget.errorText,
      isVisible: widget.isVisible,
      validations: widget.question.questionValidations,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomDropdownField<String>(
            label: '',
            activeColor: AppColors.surveyPrimary,
            activeGradient: AppColors.primaryGradient,
            items: options.map((o) => o.value ?? '').toList(),
            getLabel: (val) =>
                options
                    .firstWhere(
                      (o) => o.value == val,
                      orElse: () => options.first,
                    )
                    .label ??
                val,
            selectedValue: _highlightedOptionValue,
            onChanged: _onDropdownChanged,
          ),
          if (hasOther && _isOtherSelected) ...[
            SizedBox(height: 8.h),
            CustomTextField(
              controller: _otherController,
              label: null,
              hintText: S.of(context).other_specify_hint,
              onChanged: widget.isEditable ? _onOtherTextChanged : null,
              enabled: widget.isEditable,
            ),
          ],
        ],
      ),
    );
  }
}
