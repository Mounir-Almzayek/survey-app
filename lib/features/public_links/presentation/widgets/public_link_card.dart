import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/unified_snackbar.dart';
import '../../models/public_link.dart';
import 'qr_code_dialog.dart';

class PublicLinkCard extends StatelessWidget {
  final PublicLink publicLink;
  final VoidCallback? onTap;

  const PublicLinkCard({super.key, required this.publicLink, this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = publicLink.status;
    final s = S.of(context);
    final url = publicLink.fullUrl;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
          // Row 1: Title and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  publicLink.surveyTitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusChip(status),
            ],
          ),
          SizedBox(height: 8.h),

          // Row 2: Description (Read More)
          if (publicLink.survey?.description != null &&
              publicLink.survey!.description?.isNotEmpty == true)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: ReadMoreText(
                publicLink.survey!.description ?? "",
                trimLines: 2,
                colorClickableText: AppColors.primary,
                trimMode: TrimMode.Line,
                trimCollapsedText: s.read_more,
                trimExpandedText: ' ${s.show_less}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.secondaryText,
                  height: 1.5,
                ),
                moreStyle: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                lessStyle: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),

          // Row 3: Details
          Wrap(
            spacing: 16.w,
            runSpacing: 8.h,
            children: [
              _InfoItem(
                icon: Icons.tag_rounded,
                label: s.code_colon(publicLink.shortCode),
              ),
              _InfoItem(
                icon: Icons.people_outline_rounded,
                label: "${s.max_responses}: ${publicLink.maxResponses}",
              ),
              if (publicLink.expiresAt != null)
                _InfoItem(
                  icon: Icons.event_busy_rounded,
                  label:
                      "${s.expires_at}: ${publicLink.expiresAt!.toLocal().toString().split(' ')[0]}",
                ),
              _InfoItem(
                icon: Icons.location_on_outlined,
                label: publicLink.requireLocation
                    ? s.location_required
                    : s.not_available,
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Row 4: URL and Actions
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.survey_link,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _launchUrl(context, url),
                        child: Text(
                          url,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _ActionButton(
                      icon: Icons.copy_rounded,
                      onTap: () => _copyToClipboard(context, url, s),
                      tooltip: s.copy_link,
                    ),
                    SizedBox(width: 8.w),
                    _ActionButton(
                      icon: Icons.qr_code_2_rounded,
                      onTap: () =>
                          _showQRCode(context, url, publicLink.surveyTitle),
                      tooltip: s.show_qr_code,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(PublicLinkStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12.sp, color: status.color),
          SizedBox(width: 4.w),
          Text(
            status.label.toUpperCase(),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      // First try to check if it's launchable
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: try to launch anyway if it's a web URL, as canLaunchUrl
        // can sometimes return false on Android 11+ even with queries
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        UnifiedSnackbar.error(
          context,
          message: "Could not launch URL: ${e.toString()}",
        );
      }
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String url, S s) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      UnifiedSnackbar.success(context, message: s.link_copied);
    }
  }

  void _showQRCode(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (context) => QRCodeDialog(url: url, surveyTitle: title),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: AppColors.secondaryText),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: AppColors.secondaryText),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 18.sp, color: AppColors.primary),
        ),
      ),
    );
  }
}
