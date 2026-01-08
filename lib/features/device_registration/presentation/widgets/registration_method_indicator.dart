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

    // Determine colors and icons based on method
    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    IconData icon;
    String title;
    String description;

    switch (method) {
      case RegistrationMethod.deviceBoundKey:
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        borderColor = Colors.blue.withValues(alpha: 0.3);
        iconColor = Colors.blue;
        icon = Icons.vpn_key_rounded;
        title = locale.registration_method_device_bound_key_title;
        description = locale.registration_method_device_bound_key_description;
        break;
      case RegistrationMethod.cookieBased:
        backgroundColor = AppColors.brightWhite;
        borderColor = AppColors.border.withValues(alpha: 0.3);
        iconColor = AppColors.secondaryText;
        icon = Icons.fingerprint_rounded;
        title = locale.registration_method_cookie_based_title;
        description = locale.registration_method_cookie_based_description;
        break;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
