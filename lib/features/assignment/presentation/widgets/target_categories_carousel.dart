import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/models/survey/researcher_quota_model.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';

class TargetCategoriesCarousel extends StatefulWidget {
  final List<ResearcherQuota> quotas;
  final bool showTitle; // Added parameter

  const TargetCategoriesCarousel({
    super.key,
    required this.quotas,
    this.showTitle = true, // Default to true
  });

  @override
  State<TargetCategoriesCarousel> createState() =>
      _TargetCategoriesCarouselState();
}

class _TargetCategoriesCarouselState extends State<TargetCategoriesCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quotas.isEmpty) return const SizedBox.shrink();

    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle) ...[
          // Conditionally show title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  size: context.adaptiveIcon(20.sp),
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  s.target_categories,
                  style: TextStyle(
                    fontSize: context.adaptiveFont(16.sp),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],
        SizedBox(
          height: 160.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.quotas.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildCarouselItem(context, widget.quotas[index]);
            },
          ),
        ),
        SizedBox(height: 16.h),
        if (widget.quotas.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.quotas.length,
              (index) => _buildIndicator(index == _currentPage),
            ),
          ),
      ],
    );
  }

  Widget _buildCarouselItem(BuildContext context, ResearcherQuota quota) {
    final progresspercent = quota.completionPercentage / 100;
    final progressColor = AppColors.primary.withOpacity(
      quota.progressDisplayAlpha,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // Left Side: Circular Progress
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80.r,
                  height: 80.r,
                  child: CircularProgressIndicator(
                    value: progresspercent.clamp(0.0, 1.0),
                    strokeWidth: 8.r,
                    backgroundColor: AppColors.muted.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '${(progresspercent * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: context.adaptiveFont(16.sp),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          // Right Side: Details
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quota.demographicDescription,
                  style: TextStyle(
                    fontSize: context.adaptiveFont(16.sp),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                _buildDetailRow(
                  context,
                  Icons.check_circle_outline,
                  '${quota.progress} / ${quota.target}',
                  AppColors.secondaryText,
                ),
                SizedBox(height: 4.h),
                if (quota.isCompleted)
                  Container(
                    margin: EdgeInsets.only(top: 4.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      S.of(context).completed,
                      style: TextStyle(
                        fontSize: context.adaptiveFont(10.sp),
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: context.adaptiveIcon(14.sp), color: color),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontSize: context.adaptiveFont(12.sp),
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 8.h,
      width: isActive ? 24.w : 8.w,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.muted,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
