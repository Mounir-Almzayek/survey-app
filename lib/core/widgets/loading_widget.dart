import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../styles/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final bool withPadding;
  final double? height;
  final String? message;

  const LoadingWidget({
    super.key,
    this.withPadding = true,
    this.height,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final loadingIndicator = Center(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryStart.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          width: 32.w,
          height: 32.w,
          child: const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
        ),
      ),
    );

    if (message != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              loadingIndicator,
              SizedBox(height: 16.h),
              Text(
                message!,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: height,
      padding: withPadding ? EdgeInsets.all(16.w) : EdgeInsets.zero,
      child: loadingIndicator,
    );
  }
}
