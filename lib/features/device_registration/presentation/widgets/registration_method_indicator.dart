import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../models/registration_method.dart';

class RegistrationMethodIndicator extends StatelessWidget {
  final RegistrationMethod method;

  const RegistrationMethodIndicator({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    final isDeviceBound = method == RegistrationMethod.deviceBoundKey;
    final color = isDeviceBound ? AppColors.primary : AppColors.secondaryText;
    final icon = isDeviceBound ? Icons.security_rounded : Icons.cookie_outlined;
    final title = isDeviceBound
        ? locale.registration_method_device_bound_key_title
        : locale.registration_method_cookie_based_title;
    final description = isDeviceBound
        ? locale.registration_method_device_bound_key_description
        : locale.registration_method_cookie_based_description;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  isDeviceBound ? "REC" : "ALT",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.secondaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
