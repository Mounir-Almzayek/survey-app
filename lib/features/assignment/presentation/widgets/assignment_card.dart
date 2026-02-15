import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/models/survey/survey_model.dart';
import '../../../../core/styles/app_colors.dart';

import '../../../../core/utils/responsive_layout.dart';
import 'response_list_item.dart';
import 'assignment_actions_section.dart';
import 'status_chip.dart';
import 'description_section.dart';
import 'dates_info_section.dart';

class AssignmentCard extends StatefulWidget {
  final Survey survey;

  const AssignmentCard({super.key, required this.survey});

  @override
  State<AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<AssignmentCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final hasResponses =
        widget.survey.localResponseIds != null &&
        widget.survey.localResponseIds!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border, width: 1),
      ),
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
                    SizedBox(width: 3.w),
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
                const SizedBox(height: 16),
                AssignmentActionsSection(survey: widget.survey),
              ],
            ),
          ),
          if (hasResponses) ...[
            const Divider(height: 1),
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                      size: context.adaptiveIcon(24.sp),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s.local_responses_count(
                        widget.survey.localResponseIds!.length,
                      ),
                      style: TextStyle(
                        fontSize: context.adaptiveFont(14.sp),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  children: widget.survey.localResponseIds!
                      .map(
                        (id) => ResponseListItem(
                          responseId: id,
                          surveyId: widget.survey.id,
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
