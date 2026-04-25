import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/generated/l10n.dart';
import '../../models/survey/question_model.dart';
import '../../models/survey/question_option_model.dart';
import '../../styles/app_colors.dart';
import '../../utils/responsive_layout.dart';
import '../custom_text_field.dart';
import 'other_option_value.dart';
import 'survey_question_card.dart';

class SurveyCheckboxField extends StatefulWidget {
  final Question question;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isEditable;

  const SurveyCheckboxField({
    super.key,
    required this.question,
    required this.onChanged,
    this.selectedValues = const [],
    this.errorText,
    this.isVisible = true,
    this.isEditable = true,
  });

  @override
  State<SurveyCheckboxField> createState() => _SurveyCheckboxFieldState();
}

class _SurveyCheckboxFieldState extends State<SurveyCheckboxField> {
  late final TextEditingController _otherController;

  @override
  void initState() {
    super.initState();
    final (_, otherText) = OtherOptionValue.splitCheckboxValue(
      widget.selectedValues,
      widget.question.questionOptions,
    );
    _otherController = TextEditingController(text: otherText ?? '');
  }

  @override
  void didUpdateWidget(SurveyCheckboxField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValues == oldWidget.selectedValues) return;
    final (_, otherText) = OtherOptionValue.splitCheckboxValue(
      widget.selectedValues,
      widget.question.questionOptions,
    );
    final desired = otherText ?? '';
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

  /// Splits the current value into the regular selection list and the
  /// current Other text (always reading from the controller, since the user
  /// may have typed without the bloc round-tripping yet).
  (List<String>, String) _currentSplit() {
    final (regular, _) = OtherOptionValue.splitCheckboxValue(
      widget.selectedValues,
      widget.question.questionOptions,
    );
    return (regular, _otherController.text);
  }

  bool _isOtherChecked() {
    final other = _otherOption;
    if (other == null) return false;
    if (widget.selectedValues.contains(other.value)) return true;
    final (_, otherText) = OtherOptionValue.splitCheckboxValue(
      widget.selectedValues,
      widget.question.questionOptions,
    );
    return otherText != null && otherText.isNotEmpty;
  }

  void _toggleRegular(String value, bool currentlySelected) {
    if (!widget.isEditable) return;
    final (regular, otherText) = _currentSplit();
    final newRegular = List<String>.from(regular);
    if (currentlySelected) {
      newRegular.remove(value);
    } else {
      newRegular.add(value);
    }
    _emit(newRegular, otherText, otherChecked: _isOtherChecked());
  }

  void _toggleOther(bool currentlyChecked) {
    if (!widget.isEditable) return;
    final (regular, _) = _currentSplit();
    if (currentlyChecked) {
      // Unchecking Other → drop the text and the marker.
      _otherController.clear();
      _emit(regular, '', otherChecked: false);
    } else {
      _emit(regular, _otherController.text, otherChecked: true);
    }
  }

  void _onOtherTextChanged(String text) {
    if (!widget.isEditable) return;
    final (regular, _) = _currentSplit();
    _emit(regular, text, otherChecked: true);
  }

  void _emit(
    List<String> regular,
    String otherText, {
    required bool otherChecked,
  }) {
    final other = _otherOption;
    final trimmed = otherText.trim();
    final next = <String>[...regular];
    if (otherChecked && other != null) {
      // Append the Other payload — actual text when present, otherwise the
      // marker so the option stays selected.
      next.add(trimmed.isEmpty ? (other.value ?? '') : trimmed);
    }
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.question.questionOptions ?? const <QuestionOption>[];
    final hasOther = OtherOptionValue.hasOtherOption(options);
    final otherOption = _otherOption;
    final regular = options.where((o) => !o.isOther).toList();

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
          ...regular.map((option) {
            final isSelected = widget.selectedValues.contains(option.value);
            return _CheckboxRow(
              label: option.label ?? '',
              isSelected: isSelected,
              onTap: () => _toggleRegular(option.value ?? '', isSelected),
              enabled: widget.isEditable,
            );
          }),
          if (hasOther && otherOption != null) ...[
            _CheckboxRow(
              label: otherOption.label ?? '',
              isSelected: _isOtherChecked(),
              onTap: () => _toggleOther(_isOtherChecked()),
              enabled: widget.isEditable,
            ),
            if (_isOtherChecked()) ...[
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
        ],
      ),
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool enabled;

  const _CheckboxRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: context.responsive(
            10.h,
            tablet: 12.h,
            desktop: 14.h,
          ),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? AppColors.surveyPrimary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          color: isSelected
              ? AppColors.surveyPrimary.withOpacity(0.05)
              : AppColors.background.withOpacity(0.5),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              color: isSelected
                  ? AppColors.surveyPrimary
                  : AppColors.mutedForeground,
              size: context.adaptiveIcon(20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: context.adaptiveFont(13.sp),
                  color: isSelected
                      ? AppColors.surveyPrimary
                      : AppColors.primaryText,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
