import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/generated/l10n.dart';
import '../styles/app_colors.dart';
import 'custom_elevated_button.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64.sp,
                color: AppColors.error.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                color: AppColors.primaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 32.h),
              CustomElevatedButton(
                onPressed: onRetry,
                title: locale.retry,
                width: 160.w,
                useGradient: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
