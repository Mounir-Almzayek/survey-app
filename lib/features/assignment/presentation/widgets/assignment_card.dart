import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/models/survey/survey_model.dart';
import '../../../../core/styles/app_colors.dart';

import '../../../../core/utils/responsive_layout.dart';

import 'assignment_actions_section.dart';
import 'status_chip.dart';
import 'description_section.dart';
import 'dates_info_section.dart';
import 'target_categories_section.dart';
import 'local_responses_section.dart';

class AssignmentCard extends StatefulWidget {
  final Survey survey;

  const AssignmentCard({super.key, required this.survey});

  @override
  State<AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<AssignmentCard> {
  @override
  Widget build(BuildContext context) {
    final hasResponses =
        widget.survey.localResponseIds != null &&
        widget.survey.localResponseIds!.isNotEmpty;

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: AppColors.border.withOpacity(0.5), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.survey.title ?? "",
                            style: TextStyle(
                              fontSize: context.adaptiveFont(16.sp),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        StatusChip(status: widget.survey.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DescriptionSection(description: widget.survey.description),
                    const SizedBox(height: 12),
                    DatesInfoSection(
                      createdAt: widget.survey.createdAt,
                      availabilityStartAt: widget.survey.availabilityStartAt,
                      availabilityEndAt: widget.survey.availabilityEndAt,
                      updatedAt: widget.survey.updatedAt,
                    ),
                    if (widget.survey.assignments != null &&
                        widget.survey.assignments!.isNotEmpty &&
                        widget.survey.assignments!.first.researcherQuotas != null &&
                        widget
                            .survey
                            .assignments!
                            .first
                            .researcherQuotas!
                            .isNotEmpty) ...[
                      const SizedBox(height: 16),
                      TargetCategoriesSection(
                        quotas: widget.survey.assignments!.first.researcherQuotas!,
                      ),
                    ],
    
                    if (hasResponses) ...[
                      const SizedBox(height: 16),
                      LocalResponsesSection(
                        responseIds: widget.survey.localResponseIds!,
                        surveyId: widget.survey.id,
                      ),
                    ],
    
                    const SizedBox(height: 16),
                    AssignmentActionsSection(survey: widget.survey),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
