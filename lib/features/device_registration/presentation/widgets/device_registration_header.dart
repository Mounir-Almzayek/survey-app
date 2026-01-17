import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';

class DeviceRegistrationHeader extends StatelessWidget {
  final String? deviceName;
  final String? deviceType;
  final int? zoneId;

  const DeviceRegistrationHeader({
    super.key,
    this.deviceName,
    this.deviceType,
    this.zoneId,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Column(
      children: [
        // Premium Illustration or Icon Circle
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.device_hub_rounded,
            color: Colors.white,
            size: context.adaptiveIcon(50.sp),
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          locale.register_device,
          style: TextStyle(
            fontSize: context.adaptiveFont(24.sp),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          locale.complete_device_registration,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: context.adaptiveFont(14.sp), color: AppColors.secondaryText),
        ),
        SizedBox(height: 32.h),

        // Device Info Card
        if (deviceName != null || deviceType != null || zoneId != null)
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.brightWhite,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                if (deviceName != null)
                  _InfoTile(
                    icon: Icons.badge_outlined,
                    label: locale.device_name,
                    value: deviceName!,
                    isFirst: true,
                  ),
                if (deviceType != null)
                  _InfoTile(
                    icon: Icons.category_outlined,
                    label: locale.device_type,
                    value: deviceType!,
                  ),
                if (zoneId != null)
                  _InfoTile(
                    icon: Icons.location_on_outlined,
                    label: locale.zone,
                    value: "Zone #$zoneId",
                    isLast: true,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isFirst)
          Padding(
            padding: EdgeInsets.only(left: 44.w),
            child: Divider(
              height: 1,
              color: AppColors.border.withValues(alpha: 0.3),
            ),
          ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: context.adaptiveIcon(20.sp)),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: context.adaptiveFont(12.sp),
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: context.adaptiveFont(15.sp),
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
