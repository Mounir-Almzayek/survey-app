import 'package:flutter/material.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponseIdCard extends StatelessWidget {
  final int responseId;
  final VoidCallback onTap;

  const ResponseIdCard({
    super.key,
    required this.responseId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.assignment_turned_in_rounded,
                size: context.adaptiveIcon(24.sp),
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.response_number(responseId),
                    style: TextStyle(
                      fontSize: context.adaptiveFont(16.sp),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    s.last_updated_at('...'),
                    style: TextStyle(
                      fontSize: context.adaptiveFont(12.sp),
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: context.adaptiveIcon(16.sp),
              color: AppColors.secondaryText.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
