import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.brightWhite,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
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
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.devices_rounded,
                  color: AppColors.primary,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.register_device,
                      style: GoogleFonts.cairo(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      locale.complete_device_registration,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (deviceName != null || deviceType != null || zoneId != null) ...[
            SizedBox(height: 20.h),
            const Divider(),
            SizedBox(height: 16.h),
            if (deviceName != null)
              _InfoRow(
                icon: Icons.info_outline_rounded,
                label: locale.device_name,
                value: deviceName!,
              ),
            if (deviceType != null) ...[
              SizedBox(height: 12.h),
              _InfoRow(
                icon: Icons.laptop_rounded,
                label: locale.device_type,
                value: deviceType!,
              ),
            ],
            if (zoneId != null) ...[
              SizedBox(height: 12.h),
              _InfoRow(
                icon: Icons.map_rounded,
                label: locale.zone,
                value: zoneId.toString(),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
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
        Text(
          '$label: ',
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
    );
  }
}

