import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/models/survey/researcher_quota_model.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';

class TargetCategoriesSection extends StatefulWidget {
  final List<ResearcherQuota> quotas;

  const TargetCategoriesSection({super.key, required this.quotas});

  @override
  State<TargetCategoriesSection> createState() =>
      _TargetCategoriesSectionState();
}

class _TargetCategoriesSectionState extends State<TargetCategoriesSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.quotas.isEmpty) return const SizedBox.shrink();

    final s = S.of(context);
    final completedCount = widget.quotas.where((q) => q.isCompleted).length;
    final totalCount = widget.quotas.length;
    final overallProgress = totalCount > 0 ? completedCount / totalCount : 0.0;

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
                    Icons.pie_chart_outline,
                    size: context.adaptiveIcon(20.sp),
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    s.target_categories,
                    style: TextStyle(
                      fontSize: context.adaptiveFont(12.sp),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const Spacer(),
                  if (!_isExpanded) ...[
                    Text(
                      '$completedCount / $totalCount',
                      style: TextStyle(
                        fontSize: context.adaptiveFont(12.sp),
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: context.adaptiveIcon(16.sp),
                      height: context.adaptiveIcon(16.sp),
                      child: CircularProgressIndicator(
                        value: overallProgress,
                        strokeWidth: context.adaptiveIcon(3.sp),
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
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
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: widget.quotas
                        .map((quota) => _buildQuotaItem(context, quota))
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

  Widget _buildQuotaItem(BuildContext context, ResearcherQuota quota) {
    final progress = quota.progress;
    final target = quota.target;
    final progressPercent = quota.completionPercentage / 100;
    final Color progressColor = AppColors.primary.withOpacity(
      quota.progressDisplayAlpha,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  quota.demographicDescription,
                  style: TextStyle(
                    fontSize: context.adaptiveFont(12.sp),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (quota.isCompleted)
                Icon(Icons.check_circle, color: AppColors.primary, size: 14.sp),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progressPercent * 100).toInt()}%',
                style: TextStyle(
                  fontSize: context.adaptiveFont(12.sp),
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
              Text(
                '$progress / $target',
                style: TextStyle(
                  fontSize: context.adaptiveFont(11.sp),
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPercent.clamp(0.0, 1.0),
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
