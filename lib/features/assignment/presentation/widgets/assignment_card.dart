import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/models/survey/survey_model.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import 'response_list_item.dart';

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
                          fontSize: context.adaptiveFont(15.sp),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    _buildStatusChip(),
                  ],
                ),
                const SizedBox(height: 8),
                _buildDescription(s),
                const SizedBox(height: 12),
                _buildDatesInfo(s),
                const SizedBox(height: 16),
                _buildButtons(context, s),
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

  Widget _buildStatusChip() {
    if (widget.survey.status == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.survey.status!.name.toUpperCase(),
        style: TextStyle(
          fontSize: context.adaptiveFont(9.sp),
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDescription(S s) {
    final description = widget.survey.description ?? "";
    if (description.isEmpty) return const SizedBox.shrink();

    return ReadMoreText(
      description,
      trimLines: 2,
      colorClickableText: AppColors.primary,
      trimMode: TrimMode.Line,
      trimCollapsedText: s.read_more,
      trimExpandedText: ' ${s.show_less}',
      style: TextStyle(
        fontSize: context.adaptiveFont(12.sp),
        color: AppColors.secondaryText,
      ),
      moreStyle: TextStyle(
        fontSize: context.adaptiveFont(10.sp),
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
      lessStyle: TextStyle(
        fontSize: context.adaptiveFont(10.sp),
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildDatesInfo(S s) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          if (widget.survey.createdAt != null)
            _buildDateRow(
              Icons.calendar_today_outlined,
              s.created_at_colon(dateFormat.format(widget.survey.createdAt!)),
            ),
          if (widget.survey.availabilityStartAt != null ||
              widget.survey.availabilityEndAt != null)
            _buildDateRow(
              Icons.access_time_rounded,
              s.availability_period(
                widget.survey.availabilityStartAt != null
                    ? dateFormat.format(widget.survey.availabilityStartAt!)
                    : '...',
                widget.survey.availabilityEndAt != null
                    ? dateFormat.format(widget.survey.availabilityEndAt!)
                    : '...',
              ),
            ),
          if (widget.survey.willPublishAt != null)
            _buildDateRow(
              Icons.publish_rounded,
              s.publish_date(
                dateTimeFormat.format(widget.survey.willPublishAt!),
              ),
            ),
          if (widget.survey.updatedAt != null)
            _buildDateRow(
              Icons.update_rounded,
              s.last_update(dateTimeFormat.format(widget.survey.updatedAt!)),
            ),
        ],
      ),
    );
  }

  Widget _buildDateRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: context.adaptiveIcon(12.sp),
            color: AppColors.secondaryText.withOpacity(0.6),
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: context.adaptiveFont(9.sp),
              color: AppColors.secondaryText.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context, S s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // New Response Button
        CustomElevatedButton(
          fontSize: context.adaptiveFont(13.sp),
          width: ResponsiveLayout.value(
            context,
            mobile: 1.sw,
            tablet: 300.w,
            desktop: 400.w,
          ),
          height: ResponsiveLayout.value(
            context,
            mobile: 44.h,
            tablet: 48.h,
            desktop: 52.h,
          ),
          onPressed: () {
            context.push(
              Routes.surveyAnsweringPath,
              extra: {
                'survey': widget.survey,
                'responseId': null, // Explicitly null for new response
              },
            );
          },
          title: s.new_response,
        ),
        const SizedBox(height: 12),
        // View Completed Responses Button
        SizedBox(
          width: ResponsiveLayout.value(
            context,
            mobile: 1.sw,
            tablet: 300.w,
            desktop: 400.w,
          ),
          height: ResponsiveLayout.value(
            context,
            mobile: 44.h,
            tablet: 48.h,
            desktop: 52.h,
          ),
          child: CustomElevatedButton(
            fontSize: context.adaptiveFont(13.sp),
            width: ResponsiveLayout.value(
              context,
              mobile: 1.sw,
              tablet: 300.w,
              desktop: 400.w,
            ),
            height: ResponsiveLayout.value(
              context,
              mobile: 44.h,
              tablet: 48.h,
              desktop: 52.h,
            ),
            onPressed: () {
              context.push(
                Routes.completedResponsesPath,
                extra: {'surveyId': widget.survey.id},
              );
            },
            title: s.view_completed_responses,
          ),
        ),
      ],
    );
  }
}
