import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/survey/question_model.dart';
import '../../enums/survey_enums.dart';
import '../../styles/app_colors.dart';
import '../../utils/responsive_layout.dart';
import 'survey_question_card.dart';

class SurveyGridField extends StatelessWidget {
  final Question question;
  final Map<int, List<String>>? value; // rowId -> list of optionValues
  final ValueChanged<Map<int, List<String>>> onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isEditable;

  const SurveyGridField({
    super.key,
    required this.question,
    required this.onChanged,
    this.value,
    this.errorText,
    this.isVisible = true,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMulti = question.type == QuestionType.multiSelectGrid;
    final selectedValues = value ?? {};

    return SurveyQuestionCard(
      label: question.label,
      helpText: question.helpText,
      isRequired: question.isRequired,
      errorText: errorText,
      isVisible: isVisible,
      validations: question.questionValidations,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                SizedBox(
                  width: context.responsive(
                    100.w,
                    tablet: 120.w,
                    desktop: 140.w,
                  ),
                ), // Row label space
                ...question.questionOptions?.map(
                      (opt) => Container(
                        width: context.responsive(
                          70.w,
                          tablet: 80.w,
                          desktop: 90.w,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        alignment: Alignment.center,
                        child: Text(
                          opt.label ?? "",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: context.adaptiveFont(11.sp),
                            fontWeight: FontWeight.bold,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ),
                    ) ??
                    [],
              ],
            ),
            SizedBox(height: 12.h),
            // Data Rows
            ...question.questionRows?.map(
                  (row) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      children: [
                        SizedBox(
                          width: context.responsive(
                            100.w,
                            tablet: 120.w,
                            desktop: 140.w,
                          ),
                          child: Text(
                            row.label ?? "",
                            style: TextStyle(
                              fontSize: context.adaptiveFont(12.sp),
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                        ...question.questionOptions?.map((opt) {
                              final isSelected =
                                  selectedValues[row.id]?.contains(opt.value) ??
                                  false;
                              return Container(
                                width: context.responsive(
                                  70.w,
                                  tablet: 80.w,
                                  desktop: 90.w,
                                ),
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: isEditable
                                      ? () {
                                          final newMap =
                                              Map<int, List<String>>.from(
                                                selectedValues,
                                              );
                                          final currentSelections =
                                              List<String>.from(
                                                newMap[row.id] ?? [],
                                              );

                                          if (isMulti) {
                                            if (isSelected) {
                                              currentSelections.remove(
                                                opt.value,
                                              );
                                            } else {
                                              currentSelections.add(
                                                opt.value ?? "",
                                              );
                                            }
                                          } else {
                                            currentSelections.clear();
                                            currentSelections.add(
                                              opt.value ?? "",
                                            );
                                          }

                                          newMap[row.id] = currentSelections;
                                          onChanged(newMap);
                                        }
                                      : null,
                                  child: Container(
                                    padding: EdgeInsets.all(8.r),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? AppColors.surveyPrimary.withOpacity(
                                              0.1,
                                            )
                                          : Colors.transparent,
                                    ),
                                    child: Icon(
                                      isSelected
                                          ? (isMulti
                                                ? Icons.check_box_rounded
                                                : Icons
                                                      .radio_button_checked_rounded)
                                          : (isMulti
                                                ? Icons
                                                      .check_box_outline_blank_rounded
                                                : Icons
                                                      .radio_button_off_rounded),
                                      color: isSelected
                                          ? AppColors.surveyPrimary
                                          : AppColors.mutedForeground
                                                .withOpacity(0.5),
                                      size: context.adaptiveIcon(22.sp),
                                    ),
                                  ),
                                ),
                              );
                            }).toList() ??
                            [],
                      ],
                    ),
                  ),
                ) ??
                [],
          ],
        ),
      ),
    );
  }
}
