import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/enums/survey_enums.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/models/survey/survey_model.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/custom_dropdown_field.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/custom_radio_group_field.dart';
import '../../../../core/widgets/unified_snackbar.dart';
import '../../../../core/utils/responsive_layout.dart';

class DemographicsDialog extends StatefulWidget {
  /// When set, blocks confirming a gender/age pair whose quota is already full.
  final Survey? survey;

  const DemographicsDialog({super.key, this.survey});

  @override
  State<DemographicsDialog> createState() => _DemographicsDialogState();
}

class _DemographicsDialogState extends State<DemographicsDialog> {
  Gender? _selectedGender;
  AgeGroup? _selectedAgeGroup;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(20.r),
        constraints: BoxConstraints(maxWidth: 400.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              S.of(context).demographics_title,
              style: TextStyle(
                fontSize: context.adaptiveFont(18.sp),
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            CustomRadioGroupField<Gender>(
              label: S.of(context).gender,
              isRequired: true,
              items: Gender.values,
              selectedValue: _selectedGender,
              getLabel: (gender) {
                switch (gender) {
                  case Gender.male:
                    return S.of(context).gender_male;
                  case Gender.female:
                    return S.of(context).gender_female;
                }
              },
              onChanged: (val) {
                setState(() => _selectedGender = val);
              },
            ),
            SizedBox(height: 16.h),
            CustomDropdownField<AgeGroup>(
              label: S.of(context).age_group,
              isRequired: true,
              items: AgeGroup.values,
              selectedValue: _selectedAgeGroup,
              getLabel: (group) {
                return _formatAgeGroup(group);
              },
              onChanged: (val) {
                setState(() => _selectedAgeGroup = val);
              },
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      S.of(context).cancel,
                      style: TextStyle(
                        fontSize: context.adaptiveFont(16.sp),
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomElevatedButton(
                    title: S.of(context).start_survey,
                    onPressed: _isValid
                        ? () {
                            final s = widget.survey;
                            if (s != null &&
                                s.isDemographicQuotaFull(
                                  _selectedGender!,
                                  _selectedAgeGroup!,
                                )) {
                              UnifiedSnackbar.error(
                                context,
                                message: S
                                    .of(context)
                                    .demographic_quota_full_for_category,
                              );
                              return;
                            }
                            Navigator.of(context).pop({
                              'gender': _selectedGender,
                              'ageGroup': _selectedAgeGroup,
                            });
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get _isValid => _selectedGender != null && _selectedAgeGroup != null;

  String _formatAgeGroup(AgeGroup group) {
    final s = S.of(context);
    switch (group) {
      case AgeGroup.age18_29:
        return s.age_18_29;
      case AgeGroup.age30_39:
        return s.age_30_39;
      case AgeGroup.age40_49:
        return s.age_40_49;
      case AgeGroup.age50_59:
        return s.age_50_59;
      case AgeGroup.age60_69:
        return s.age_60_69;
      case AgeGroup.age70_79:
        return s.age_70_79;
      case AgeGroup.age80_89:
        return s.age_80_89;
      case AgeGroup.age90_99:
        return s.age_90_99;
      case AgeGroup.age100Plus:
        return s.age_100_plus;
    }
  }
}
