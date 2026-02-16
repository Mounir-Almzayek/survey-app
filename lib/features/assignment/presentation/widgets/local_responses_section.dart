import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import 'response_list_item.dart';

class LocalResponsesSection extends StatefulWidget {
  final List<int> responseIds;
  final int surveyId;

  const LocalResponsesSection({
    super.key,
    required this.responseIds,
    required this.surveyId,
  });

  @override
  State<LocalResponsesSection> createState() => _LocalResponsesSectionState();
}

class _LocalResponsesSectionState extends State<LocalResponsesSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.responseIds.isEmpty) return const SizedBox.shrink();

    final s = S.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(12),
              bottom: Radius.circular(_isExpanded ? 0 : 12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: context.adaptiveIcon(20.sp),
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    s.local_responses_count(widget.responseIds.length),
                    style: TextStyle(
                      fontSize: context.adaptiveFont(12.sp),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.secondaryText,
                    size: context.adaptiveIcon(20.sp),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
              child: Column(
                children: [
                  const Divider(height: 1),
                  Column(
                    children: widget.responseIds
                        .map(
                          (id) => ResponseListItem(
                            responseId: id,
                            surveyId: widget.surveyId,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
