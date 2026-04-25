import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../styles/app_colors.dart';
import '../../models/survey/question_validation_model.dart';
import '../../utils/responsive_layout.dart';
import '../../validation/live_validation_controller.dart';

class SurveyQuestionCard extends StatelessWidget {
  final String? label;
  final String? helpText;
  final bool? isRequired;
  final Widget child;
  final String? errorText;
  final bool isVisible;
  final List<QuestionValidation>? validations;
  final LiveValidationController? liveController;

  const SurveyQuestionCard({
    super.key,
    this.label,
    this.helpText,
    this.isRequired = false,
    required this.child,
    this.errorText,
    this.isVisible = true,
    this.validations,
    this.liveController,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    final locale = Localizations.localeOf(context).languageCode;

    // Rebuild on live-validation changes so the card border (and error text)
    // reflect typing-time errors, not only submit-time ones. Falls back to a
    // dummy listenable when there's no live controller.
    return ListenableBuilder(
      listenable: liveController ?? const _AlwaysNotifier(),
      builder: (context, _) {
        final shownError = errorText ?? liveController?.error;
        return _buildCard(context, locale, shownError);
      },
    );
  }

  Widget _buildCard(BuildContext context, String locale, String? shownError) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 8.h,
        horizontal: context.responsive(16.w, tablet: 20.w, desktop: 24.w),
      ),
      padding: EdgeInsets.all(
        context.responsive(16.r, tablet: 20.r, desktop: 24.r),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: shownError != null
              ? AppColors.destructive
              : AppColors.border.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                fontSize: context.adaptiveFont(14.sp),
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
                fontFamily: 'Cairo', // Use app font
              ),
              children: [
                if (isRequired != null && isRequired!)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppColors.destructive,
                      fontSize: context.adaptiveFont(14.sp),
                    ),
                  ),
              ],
            ),
          ),
          if (helpText != null && helpText!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              helpText!,
              style: TextStyle(
                fontSize: context.adaptiveFont(11.sp),
                color: AppColors.secondaryText,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          child,
          if (validations != null && validations!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: validations!.map((qv) {
                final validation = qv.validation;
                if (validation == null || validation.isActive == false) {
                  return const SizedBox.shrink();
                }

                final title = locale == 'ar'
                    ? validation.arTitle
                    : validation.enTitle;
                if (title == null) return const SizedBox.shrink();

                final values = qv.values;
                String displayText = title;

                if (values.isNotEmpty) {
                  // Standardize value retrieval for various rule types
                  final dynamic vMin = values['min'] ?? values['start'];
                  final dynamic vMax = values['max'] ?? values['end'];
                  final dynamic vVal = values['value'];

                  String? sMin = vMin?.toString();
                  String? sMax = vMax?.toString();
                  String? sVal = vVal?.toString();

                  // Format if they look like dates/times
                  sMin = _formatIfDate(sMin, locale);
                  sMax = _formatIfDate(sMax, locale);
                  sVal = _formatIfDate(sVal, locale);

                  if (sMin != null && sMax != null) {
                    displayText = '$title: $sMin – $sMax';
                  } else if (sMin != null) {
                    displayText = '$title: $sMin+';
                  } else if (sMax != null) {
                    displayText = '$title: ≤$sMax';
                  } else if (sVal != null) {
                    displayText = '$title: $sVal';
                  }
                }

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: context.adaptiveFont(10.sp),
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (shownError != null)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                shownError,
                style: TextStyle(
                  fontSize: context.adaptiveFont(11.sp),
                  color: AppColors.destructive,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String? _formatIfDate(String? value, String locale) {
    if (value == null || value.isEmpty) return null;

    // Check if it's a date/time string
    // YYYY-MM-DD
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      final dt = DateTime.tryParse(value);
      if (dt != null) return DateFormat.yMd(locale).format(dt);
    }
    // HH:mm:ss or HH:mm
    if (RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$').hasMatch(value)) {
      final dt = DateTime.tryParse("1970-01-01 $value");
      if (dt != null) return DateFormat.jm(locale).format(dt);
    }
    // YYYY-MM-DD HH:mm:ss
    if (RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$').hasMatch(value)) {
      final dt = DateTime.tryParse(value);
      if (dt != null) return DateFormat.yMd(locale).add_jm().format(dt);
    }

    return value;
  }
}

class _AlwaysNotifier extends Listenable {
  const _AlwaysNotifier();
  @override
  void addListener(VoidCallback _) {}
  @override
  void removeListener(VoidCallback _) {}
}
