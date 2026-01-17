import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../styles/app_colors.dart';
import '../utils/responsive_layout.dart';

class SaudiCountryKey extends StatelessWidget {
  const SaudiCountryKey({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: context.responsive(10.h, tablet: 12.h, desktop: 14.h),
      ),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+966',
            style: TextStyle(
              fontSize: context.adaptiveFont(14.sp),
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
            textDirection: TextDirection.ltr,
          ),
          SizedBox(width: 8.w),
          Text('🇸🇦', style: TextStyle(fontSize: context.adaptiveIcon(18.sp))),
        ],
      ),
    );
  }
}
