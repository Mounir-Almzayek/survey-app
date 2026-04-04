import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/unified_snackbar.dart';

/// Dialog showing generated short link: QR code, link text, and copy button.
class ShortLinkResultDialog extends StatelessWidget {
  final String fullUrl;
  final String surveyTitle;
  final DateTime? expiresAt;

  /// Shown when [expiresAt] is null (e.g. server does not return a datetime).
  final int? validityMinutes;

  const ShortLinkResultDialog({
    super.key,
    required this.fullUrl,
    required this.surveyTitle,
    this.expiresAt,
    this.validityMinutes,
  });

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: fullUrl));
    if (context.mounted) {
      UnifiedSnackbar.success(context, message: S.of(context).link_copied);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text(
        s.link_ready,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: context.adaptiveFont(16.sp),
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      ),
      content: SizedBox(
        width: context.responsive(280.w, tablet: 320.w, desktop: 360.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: fullUrl,
                version: QrVersions.auto,
                size: context.responsive(200.w, tablet: 220.w, desktop: 240.w),
                backgroundColor: Colors.white,
                gapless: false,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              s.survey_link,
              style: TextStyle(
                fontSize: context.adaptiveFont(10.sp),
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText,
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: SelectableText(
                fullUrl,
                style: TextStyle(
                  fontSize: context.adaptiveFont(11.sp),
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            InkWell(
              onTap: () => _copyLink(context),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.copy_rounded,
                      size: context.adaptiveIcon(20.sp),
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      s.copy_link,
                      style: TextStyle(
                        fontSize: context.adaptiveFont(13.sp),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (expiresAt != null) ...[
              SizedBox(height: 12.h),
              Text(
                '${s.expires_at}: ${DateFormat('dd/MM/yyyy HH:mm').format(expiresAt!)}',
                style: TextStyle(
                  fontSize: context.adaptiveFont(10.sp),
                  color: AppColors.secondaryText,
                ),
              ),
            ] else if (validityMinutes != null) ...[
              SizedBox(height: 12.h),
              Text(
                s.survey_available_for_duration(validityMinutes!),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.adaptiveFont(10.sp),
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(context),
          child: Text(
            s.close,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
