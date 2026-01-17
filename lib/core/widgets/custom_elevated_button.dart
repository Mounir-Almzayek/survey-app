import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/app_colors.dart';
import '../utils/responsive_layout.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final bool isLoading;
  final bool disabled;
  final bool useGradient;
  final double? width;
  final double? height;
  final double? fontSize;
  final IconData? icon;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.isLoading = false,
    this.disabled = false,
    this.useGradient = true,
    this.width,
    this.height,
    this.fontSize,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isButtonDisabled = disabled || isLoading;
    final borderRadius = BorderRadius.circular(14.r);

    return Container(
      width: width ?? double.infinity,
      height: height ?? context.responsive(48.h, tablet: 52.h, desktop: 56.h),
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: fontSize ?? context.adaptiveFont(14.sp),
                          fontWeight: FontWeight.bold,
                          color: isButtonDisabled
                              ? AppColors.mutedForeground
                              : Colors.white,
                        ),
                      ),
                      if (icon != null) ...[
                        SizedBox(width: 8.w),
                        Icon(
                          icon,
                          color: isButtonDisabled
                              ? AppColors.mutedForeground
                              : Colors.white,
                          size: context.adaptiveIcon(16.sp),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
