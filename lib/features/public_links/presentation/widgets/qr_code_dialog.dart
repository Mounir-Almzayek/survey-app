import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/l10n/generated/l10n.dart';

class QRCodeDialog extends StatelessWidget {
  final String url;
  final String surveyTitle;

  const QRCodeDialog({super.key, required this.url, required this.surveyTitle});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text(
        surveyTitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      ),
      content: SizedBox(
        width: 250.w,
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
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                width: 200.w,
                height: 200.w,
                child: QrImageView(
                  data: url,
                  version: QrVersions.auto,
                  size: 200.w,
                  backgroundColor: Colors.white,
                  gapless: false,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              s.scan_qr_code,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            s.close,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
