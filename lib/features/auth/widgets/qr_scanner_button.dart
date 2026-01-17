import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../../qr_scanner/presentation/qr_scanner_page.dart';
import '../../device_registration/presentation/device_registration_page.dart';
import '../../../core/styles/app_colors.dart';

class QRScannerButton extends StatelessWidget {
  const QRScannerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          try {
            final result = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (context) => const QrScannerPage(returnCodeOnly: true),
              ),
            );

            if (!context.mounted) return;

            if (result == null || result.isEmpty) {
              // User cancelled or no result
              return;
            }

            // Extract token from QR code
            String? token;
            if (result.contains('token=')) {
              final uri = Uri.tryParse(result);
              token = uri?.queryParameters['token'];
            } else {
              // If it's a direct token, use it as is
              token = result.trim();
            }

            if (token != null && token.isNotEmpty && context.mounted) {
              // Navigate to device registration with token
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeviceRegistrationPage(token: token),
                ),
              );
            } else if (context.mounted) {
              // Show error if token extraction failed
              UnifiedSnackbar.error(
                context,
                message: 'Invalid QR code: Token not found',
              );
            }
          } catch (e) {
            if (context.mounted) {
              UnifiedSnackbar.error(context, message: 'Error: ${e.toString()}');
            }
          }
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.qr_code_scanner_rounded,
            color: AppColors.primary,
            size: context.adaptiveIcon(24.sp),
          ),
        ),
      ),
    );
  }
}
