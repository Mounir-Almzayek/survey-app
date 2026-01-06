import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../models/public_link.dart';

class ShareButton extends StatelessWidget {
  final PublicLink link;

  const ShareButton({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return OutlinedButton.icon(
      onPressed: () => _shareLink(context, locale),
      icon: Icon(Icons.share_rounded, size: 18.sp),
      label: Text(
        locale.share_link,
        style: GoogleFonts.cairo(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary, width: 1.5),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Future<void> _shareLink(BuildContext context, S locale) async {
    try {
      final subject = locale.share_link_subject(link.surveyTitle);
      await Share.share(
        link.fullUrl,
        subject: subject,
      );
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }
}

