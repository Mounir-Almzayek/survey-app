import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/utils/responsive_layout.dart';

class SurveyEmptyState extends StatelessWidget {
  final bool isSearch;
  final VoidCallback? onAction;

  const SurveyEmptyState({super.key, this.isSearch = false, this.onAction});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200.w,
              height: 200.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isSearch
                      ? Icons.search_off_rounded
                      : Icons.assignment_rounded,
                  size: 80.sp,
                  color: AppColors.primary.withOpacity(0.4),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              isSearch ? s.no_data : s.no_surveys_available,
              style: TextStyle(
                fontSize: context.adaptiveFont(18.sp),
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              isSearch
                  ? s.search_no_results_subtitle
                  : s.no_surveys_available_subtitle,
              style: TextStyle(
                fontSize: context.adaptiveFont(13.sp),
                color: AppColors.secondaryText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  elevation: 0,
                ),
                icon: Icon(
                  isSearch ? Icons.refresh_rounded : Icons.sync_rounded,
                ),
                label: Text(isSearch ? s.retry : s.sync),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
