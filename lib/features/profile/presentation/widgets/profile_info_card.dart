import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../models/user.dart';

class ProfileInfoCard extends StatelessWidget {
  final User user;

  const ProfileInfoCard({super.key, required this.user});

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Derive role/roles text similar to web user-nav (join user_types names)
    final rolesText = user.userTypes.isNotEmpty
        ? user.userTypes.map((t) => t.name).join(', ')
        : null;

    final initials = _getInitials(user.name);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.all(
        context.responsive(24.r, tablet: 32.r, desktop: 40.r),
      ),
      child: Column(
        children: [
          Container(
            width: context.responsive(80.w, tablet: 100.w, desktop: 120.w),
            height: context.responsive(80.w, tablet: 100.w, desktop: 120.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: context.adaptiveFont(24.sp),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            user.name,
            style: TextStyle(
              fontSize: context.adaptiveFont(18.sp),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            user.email,
            style: TextStyle(
              fontSize: context.adaptiveFont(12.sp),
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          if (rolesText != null && rolesText.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                rolesText,
                style: TextStyle(
                  fontSize: context.adaptiveFont(10.sp),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
