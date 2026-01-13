import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/app_colors.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final bool isLoading;
  final bool disabled;
  final bool useGradient;
  final double? width;
  final double? height;
  final double? fontSize;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.isLoading = false,
    this.disabled = false,
    this.useGradient = true,
    this.width,
    this.height,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final bool isButtonDisabled = disabled || isLoading;
    final borderRadius = BorderRadius.circular(14.r);

    return Container(
      width: width ?? double.infinity,
      height: height ?? 52.h,
      decoration: BoxDecoration(
        gradient: (isButtonDisabled || !useGradient)
            ? null
            : AppColors.primaryGradient,
        color: isButtonDisabled
            ? AppColors.muted
            : (useGradient ? null : AppColors.primary),
        borderRadius: borderRadius,
        boxShadow: isButtonDisabled
            ? null
            : [
                BoxShadow(
                  color: AppColors.primaryStart.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isButtonDisabled ? null : onPressed,
          borderRadius: borderRadius,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      color: useGradient ? Colors.white : AppColors.primary,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    title,
                    style: TextStyle(
                      fontSize: fontSize?.sp ?? 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isButtonDisabled
                          ? AppColors.mutedForeground
                          : Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
