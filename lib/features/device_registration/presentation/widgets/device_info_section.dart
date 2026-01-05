import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/models/fingerprint.dart';

class DeviceInfoSection extends StatelessWidget {
  final Fingerprint fingerprint;

  const DeviceInfoSection({super.key, required this.fingerprint});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.brightWhite,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.smartphone_rounded,
                color: AppColors.primary,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  locale.device_information,
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _InfoItem(
            icon: Icons.web_rounded,
            label: locale.browser,
            value: fingerprint.browser,
          ),
          SizedBox(height: 16.h),
          _InfoItem(
            icon: Icons.laptop_rounded,
            label: locale.operating_system,
            value: fingerprint.os,
          ),
          SizedBox(height: 16.h),
          _InfoItem(
            icon: Icons.smartphone_rounded,
            label: locale.device_type,
            value: fingerprint.deviceType,
          ),
          SizedBox(height: 16.h),
          _InfoItem(
            icon: Icons.monitor_rounded,
            label: locale.screen_resolution,
            value: '${fingerprint.screenWidth} × ${fingerprint.screenHeight}',
          ),
          SizedBox(height: 16.h),
          _InfoItem(
            icon: Icons.memory_rounded,
            label: locale.ram,
            value: fingerprint.ramGB > 0
                ? '${fingerprint.ramGB} ${locale.gb}'
                : locale.not_available,
          ),
          SizedBox(height: 16.h),
          _InfoItem(
            icon: Icons.speed_rounded,
            label: locale.processor_cores,
            value: fingerprint.processorCores > 0
                ? fingerprint.processorCores.toString()
                : locale.not_available,
          ),
          SizedBox(height: 16.h),
          _InfoItem(
            icon: Icons.touch_app_rounded,
            label: locale.max_touch_points,
            value: fingerprint.maxTouchPoints > 0
                ? fingerprint.maxTouchPoints.toString()
                : locale.not_available,
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

