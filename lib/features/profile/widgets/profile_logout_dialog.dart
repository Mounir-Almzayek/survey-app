import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_colors.dart';
import '../bloc/profile/profile_bloc.dart';

class ProfileLogoutDialog extends StatelessWidget {
  const ProfileLogoutDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const ProfileLogoutDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLogoutSuccess) {
          Navigator.of(context).pop(); // Close dialog
          context.go(Routes.loginPath);
        }
      },
      builder: (context, state) {
        final isLoading = state is ProfileLoading;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            locale.log_out,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          content: Text(
            locale.logout_message, // Make sure this exists in arb
            style: GoogleFonts.cairo(
              color: AppColors.secondaryText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(
                locale.cancel,
                style: GoogleFonts.cairo(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 100.w,
              height: 40.h,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        context.read<ProfileBloc>().add(const Logout());
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        locale.confirm,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
