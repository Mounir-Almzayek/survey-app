import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/survey/question_model.dart';
import '../../enums/survey_enums.dart';
import '../../styles/app_colors.dart';
import 'survey_question_card.dart';

class SurveyGridField extends StatelessWidget {
  final Question question;
  final Map<int, List<String>>? value; // rowId -> list of optionValues
  final ValueChanged<Map<int, List<String>>> onChanged;
  final String? errorText;
  final bool isVisible;

  const SurveyGridField({
    super.key,
    required this.question,
    required this.onChanged,
    this.value,
    this.errorText,
    this.isVisible = true,
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                SizedBox(width: 120.w), // Row label space
                ...question.questionOptions?.map(
                      (opt) => Container(
                        width: 80.w,
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        alignment: Alignment.center,
                        child: Text(
                          opt.label ?? "",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
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
                          width: 120.w,
                          child: Text(
                            row.label ?? "",
                            style: TextStyle(
                              fontSize: 13.sp,
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
                                width: 80.w,
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () {
                                    final newMap = Map<int, List<String>>.from(
                                      selectedValues,
                                    );
                                    final currentSelections = List<String>.from(
                                      newMap[row.id] ?? [],
                                    );

                                    if (isMulti) {
                                      if (isSelected) {
                                        currentSelections.remove(opt.value);
                                      } else {
                                        currentSelections.add(opt.value ?? "");
                                      }
                                    } else {
                                      currentSelections.clear();
                                      currentSelections.add(opt.value ?? "");
                                    }

                                    newMap[row.id] = currentSelections;
                                    onChanged(newMap);
                                  },
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
                                      size: 24.sp,
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
