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
    final hasNotes = record.notes != null && record.notes!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: record.status.color.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header with Status & Device Name
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: record.status.color.withValues(alpha: 0.05),
                  border: Border(
                    bottom: BorderSide(
                      color: record.status.color.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: record.status.color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.devices_other_rounded,
                        size: context.adaptiveIcon(20.sp),
                        color: record.status.color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.physicalDeviceName,
                            style: TextStyle(
                              fontSize: context.adaptiveFont(15.sp),
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryText,
                            ),
                          ),
                          if (record.physicalDeviceType != null)
                            Text(
                              record.physicalDeviceType!,
                              style: TextStyle(
                                fontSize: context.adaptiveFont(11.sp),
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(context),
                  ],
                ),
              ),

              // 2. Transfer Path (From -> To)
              Padding(
                padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 8.r),
                child: Row(
                  children: [
                    _buildUserNode(
                      context,
                      label: locale.from,
                      name: record.fromUserName,
                      email: record.fromUserEmail,
                      icon: Icons.person_outline_rounded,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: context.adaptiveIcon(18.sp),
                        color: AppColors.secondaryText.withValues(alpha: 0.3),
                      ),
                    ),
                    _buildUserNode(
                      context,
                      label: locale.to,
                      name: record.toUserName,
                      email: record.toUserEmail,
                      icon: Icons.person_add_alt_1_rounded,
                      isReceiver: true,
                    ),
                  ],
                ),
              ),

              // 3. Notes Section (If exists)
              if (hasNotes)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.r,
                    vertical: 8.r,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.notes_rounded,
                          size: context.adaptiveIcon(14.sp),
                          color: AppColors.secondaryText,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            record.notes!,
                            style: TextStyle(
                              fontSize: context.adaptiveFont(11.sp),
                              color: AppColors.primaryText.withValues(
                                alpha: 0.8,
                              ),
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 4. Footer: Dates & Actions
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: context.adaptiveIcon(14.sp),
                      color: AppColors.secondaryText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(record.createdAt),
                      style: TextStyle(
                        fontSize: context.adaptiveFont(11.sp),
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (record.isPending && onVerify != null)
                      ElevatedButton.icon(
                        onPressed: onVerify,
                        icon: Icon(
                          Icons.verified_user_rounded,
                          size: context.adaptiveIcon(16.sp),
                        ),
                        label: Text(locale.verify_custody),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          textStyle: TextStyle(
                            fontSize: context.adaptiveFont(12.sp),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (record.isVerified)
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: context.adaptiveIcon(14.sp),
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(record.verifiedAt!),
                            style: TextStyle(
                              fontSize: context.adaptiveFont(11.sp),
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserNode(
    BuildContext context, {
    required String label,
    String? name,
    String? email,
    required IconData icon,
    bool isReceiver = false,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: isReceiver
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: context.adaptiveFont(9.sp),
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isReceiver) ...[
                Icon(
                  icon,
                  size: context.adaptiveIcon(14.sp),
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  name ?? email ?? '---',
                  style: TextStyle(
                    fontSize: context.adaptiveFont(12.sp),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isReceiver) ...[
                const SizedBox(width: 6),
                Icon(
                  icon,
                  size: context.adaptiveIcon(14.sp),
                  color: AppColors.accent,
                ),
              ],
            ],
          ),
          if (email != null && name != null)
            Text(
              email,
              style: TextStyle(
                fontSize: context.adaptiveFont(10.sp),
                color: AppColors.secondaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
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
