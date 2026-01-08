import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/services.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/unified_snackbar.dart';
import '../../models/public_link.dart';
import 'share_button.dart';
import 'qr_code_generator.dart';

class PublicLinkCard extends StatelessWidget {
  final PublicLink link;

  const PublicLinkCard({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.3),
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
                  link.surveyTitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              _buildStatusBadge(context),
            ],
          ),
          SizedBox(height: 12.h),

          // Short code
          Row(
            children: [
              Icon(
                Icons.link_rounded,
                size: 16.sp,
                color: AppColors.secondaryText,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  link.shortCode,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.copy_rounded, size: 18.sp),
                color: AppColors.primary,
                onPressed: () => _copyLink(context, locale),
                tooltip: locale.copy_link,
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Full URL
          GestureDetector(
            onTap: () => _copyLink(context, locale),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      link.fullUrl,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.copy_rounded,
                    size: 14.sp,
                    color: AppColors.secondaryText,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Stats
          Row(
            children: [
              if (link.maxResponses != null) ...[
                _buildStat(
                  context,
                  Icons.people_outline_rounded,
                  '${link.currentResponses ?? 0}/${link.maxResponses}',
                ),
                SizedBox(width: 16.w),
              ],
              if (link.requireLocation) ...[
                _buildStat(
                  context,
                  Icons.location_on_outlined,
                  locale.location_required,
                ),
                SizedBox(width: 16.w),
              ],
              if (link.expiresAt != null) ...[
                _buildStat(
                  context,
                  Icons.access_time_rounded,
                  _formatExpiryDate(link.expiresAt!),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),

          // Actions
          Row(
            children: [
              Expanded(child: ShareButton(link: link)),
              SizedBox(width: 8.w),
              IconButton(
                icon: Icon(Icons.qr_code_rounded, size: 20.sp),
                color: AppColors.primary,
                onPressed: () => _showQRCode(context),
                tooltip: locale.show_qr_code,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final color = _getStatusColor();
    final text = _getStatusText();

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
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.secondaryText),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (!link.isAvailable) {
      if (link.isExpired) return AppColors.error;
      if (link.hasReachedMaxResponses) return AppColors.warning;
      return AppColors.secondaryText;
    }
    return AppColors.success;
  }

  String _getStatusText() {
    if (!link.isAvailable) {
      if (link.isExpired) return 'EXPIRED';
      if (link.hasReachedMaxResponses) return 'FULL';
      return link.status;
    }
    return 'ACTIVE';
  }

  String _formatExpiryDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else {
      return 'Expiring soon';
    }
  }

  void _copyLink(BuildContext context, S locale) {
    Clipboard.setData(ClipboardData(text: link.fullUrl));
    UnifiedSnackbar.success(context, message: locale.link_copied);
  }

  void _showQRCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => QRCodeGenerator(link: link),
    );
  }
}
