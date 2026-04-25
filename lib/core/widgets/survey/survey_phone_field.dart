import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import '../../models/survey/question_model.dart';
import '../../styles/app_colors.dart';
import '../../validation/live_validation_controller.dart';
import 'survey_question_card.dart';

/// Phone number input with country selector + validation.
///
/// Emits an E.164 string (e.g. `+966501234567`) or null when empty.
/// If the user types `+<dial>` into the national-number box we detect the
/// country, switch the selector, and strip the prefix so the field shows only
/// the national portion — mirroring the web frontend's `handleCountryChange`.
class SurveyPhoneField extends StatefulWidget {
  final Question question;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isEditable;
  final String defaultCountryCode;
  final LiveValidationController? validationController;

  const SurveyPhoneField({
    super.key,
    required this.question,
    required this.onChanged,
    this.value,
    this.errorText,
    this.isVisible = true,
    this.isEditable = true,
    this.defaultCountryCode = 'SA',
    this.validationController,
  });

  @override
  State<SurveyPhoneField> createState() => _SurveyPhoneFieldState();
}

class _SurveyPhoneFieldState extends State<SurveyPhoneField> {
  late TextEditingController _controller;
  late String _countryCode;
  late String _dialCode;

  @override
  void initState() {
    super.initState();
    _countryCode = widget.defaultCountryCode;
    _dialCode = _defaultDial(widget.defaultCountryCode);
    _controller = TextEditingController(
      text: _stripDial(widget.value ?? '', _dialCode),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _defaultDial(String iso) {
    switch (iso.toUpperCase()) {
      case 'SA': return '966';
      case 'AE': return '971';
      case 'EG': return '20';
      case 'KW': return '965';
      case 'QA': return '974';
      default:   return '966';
    }
  }

  String _stripDial(String raw, String dial) {
    final s = raw.trim();
    if (s.startsWith('+$dial')) return s.substring(1 + dial.length);
    if (s.startsWith(dial))     return s.substring(dial.length);
    return s;
  }

  void _onChanged(String national) {
    if (national.startsWith('+')) {
      try {
        final parsed = PhoneNumber.parse(national);
        final newDial = parsed.countryCode;
        if (newDial.isNotEmpty) {
          final rest = parsed.nsn;
          _controller.value = TextEditingValue(
            text: rest,
            selection: TextSelection.collapsed(offset: rest.length),
          );
          setState(() => _dialCode = newDial);
          widget.onChanged('+$newDial$rest');
          return;
        }
      } catch (_) {/* fall through */}
    }
    final trimmed = national.trim();
    final emitted = trimmed.isEmpty ? null : '+$_dialCode$trimmed';
    widget.onChanged(emitted);
    widget.validationController?.onChanged(emitted);
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
      child: AbsorbPointer(
        absorbing: !widget.isEditable,
        child: Opacity(
          opacity: widget.isEditable ? 1.0 : 0.6,
          child: IntlPhoneField(
            controller: _controller,
            initialCountryCode: _countryCode,
            disableLengthCheck: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 14.h,
              ),
            ),
            onCountryChanged: (c) => setState(() {
              _countryCode = c.code;
              _dialCode = c.dialCode;
            }),
            onChanged: (p) => _onChanged(p.number),
          ),
        ),
      ),
    );
  }
}
