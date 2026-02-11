import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../models/researcher_profile_response_model.dart';

class ResearcherBasicInfoCard extends StatelessWidget {
  final ResearcherUserModel user;

  const ResearcherBasicInfoCard({super.key, required this.user});

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
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
        context.responsive(24.r, tablet: 32.r, desktop: 24.0),
      ),
      child: Column(
        children: [
          Container(
            width: context.responsive(80.w, tablet: 100.w, desktop: 100.0),
            height: context.responsive(80.w, tablet: 100.w, desktop: 100.0),
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
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            user.name,
            style: TextStyle(
              fontSize: context.adaptiveFont(20.sp),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            user.email,
            style: TextStyle(
              fontSize: context.adaptiveFont(14.sp),
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          if (user.mobile != null) ...[
            SizedBox(height: 4.h),
            Text(
              user.mobile!,
              style: TextStyle(
                fontSize: context.adaptiveFont(14.sp),
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
