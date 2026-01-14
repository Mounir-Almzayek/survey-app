import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/models/survey/survey_model.dart';
import '../../../../core/styles/app_colors.dart';
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
                        style: const TextStyle(
                          fontSize: 18,
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
                _buildAddButton(context, s),
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
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s.local_responses_count(
                        widget.survey.localResponseIds!.length,
                      ),
                      style: const TextStyle(
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
        style: const TextStyle(
          fontSize: 10,
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
      style: const TextStyle(fontSize: 14, color: AppColors.secondaryText),
      moreStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
      lessStyle: const TextStyle(
        fontSize: 12,
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
          Icon(icon, size: 14, color: AppColors.secondaryText.withOpacity(0.6)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.secondaryText.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, S s) {
    return Center(
      child: CustomElevatedButton(
        fontSize: 14,
        width: 230.w,
        height: 45.h,
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
    );
  }
}
