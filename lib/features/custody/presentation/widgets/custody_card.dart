import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../models/custody_record.dart';

class CustodyCard extends StatelessWidget {
  final CustodyRecord record;
  final VoidCallback? onTap;
  final VoidCallback? onVerify;

  const CustodyCard({
    super.key,
    required this.record,
    this.onTap,
    this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: record.status.color.withValues(alpha: 0.3),
            width: 1,
          ),
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
            // Header with status
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.physicalDeviceName,
                    style: TextStyle(
                      fontSize: context.adaptiveFont(14.sp),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
                _buildStatusBadge(context),
              ],
            ),
            SizedBox(height: 12.h),

            // Device info
            if (record.physicalDeviceType != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.devices_rounded,
                    size: context.adaptiveIcon(16.sp),
                    color: AppColors.secondaryText,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    record.physicalDeviceType!,
                    style: TextStyle(
                      fontSize: context.adaptiveFont(12.sp),
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],

            // From user
            if (record.fromUserEmail != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: context.adaptiveIcon(16.sp),
                    color: AppColors.secondaryText,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      record.fromUserName ?? record.fromUserEmail!,
                      style: TextStyle(
                        fontSize: context.adaptiveFont(12.sp),
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.only(left: 24.w),
                child: Text(
                  record.fromUserEmail!,
                  style: TextStyle(
                    fontSize: context.adaptiveFont(10.sp),
                    color: AppColors.secondaryText.withValues(alpha: 0.7),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],

            // To user
            if (record.toUserEmail != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.person_add_outlined,
                    size: context.adaptiveIcon(16.sp),
                    color: AppColors.secondaryText,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      record.toUserName ?? record.toUserEmail!,
                      style: TextStyle(
                        fontSize: context.adaptiveFont(12.sp),
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.only(left: 24.w),
                child: Text(
                  record.toUserEmail!,
                  style: TextStyle(
                    fontSize: context.adaptiveFont(12.sp),
                    color: AppColors.secondaryText.withValues(alpha: 0.7),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],

            // Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: context.adaptiveIcon(14.sp),
                  color: AppColors.secondaryText,
                ),
                SizedBox(width: 4.w),
                Text(
                  _formatDate(record.createdAt),
                  style: TextStyle(
                    fontSize: context.adaptiveFont(12.sp),
                    color: AppColors.secondaryText,
                  ),
                ),
                if (record.verifiedAt != null) ...[
                  SizedBox(width: 16.w),
                  Icon(
                    Icons.check_circle_outline,
                    size: context.adaptiveIcon(14.sp),
                    color: AppColors.success,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _formatDate(record.verifiedAt!),
                    style: TextStyle(fontSize: context.adaptiveFont(12.sp), color: AppColors.success),
                  ),
                ],
              ],
            ),

            // Action button for pending records
            if (record.isPending && onVerify != null) ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    locale.verify_custody,
                    style: TextStyle(
                      fontSize: context.adaptiveFont(13.sp),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final color = record.status.color;
    final text = record.status.label(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: context.adaptiveFont(9.sp),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
