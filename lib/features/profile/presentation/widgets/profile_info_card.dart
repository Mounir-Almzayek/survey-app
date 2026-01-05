import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/network/api_config.dart';
import '../../models/user.dart';
import '../../../image_downloader/presentation/network_image_viewer.dart';

class ProfileInfoCard extends StatelessWidget {
  final User user;

  const ProfileInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final imageUrl = user.image != null && user.image!.isNotEmpty
        ? APIConfig.getFullImageUrl(user.image!)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          _ProfileImage(imageUrl: imageUrl),
          SizedBox(height: 16.h),
          Text(
            user.name,
            style: GoogleFonts.cairo(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            user.email,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          const Divider(height: 1),
          SizedBox(height: 20.h),
          
          if (user.phone != null && user.phone!.isNotEmpty)
            _InfoRow(
              icon: Icons.phone_android_rounded,
              label: locale.phone,
              value: user.phone!,
            ),
          
          if (user.company != null && user.company!.isNotEmpty)
            _InfoRow(
              icon: Icons.business_rounded,
              label: locale.company,
              value: user.company!,
            ),
            
          if (user.position != null && user.position!.isNotEmpty)
            _InfoRow(
              icon: Icons.work_outline_rounded,
              label: locale.position,
              value: user.position!,
            ),

          if (user.entity != null && user.entity!.isNotEmpty)
            _InfoRow(
              icon: Icons.account_balance_rounded,
              label: locale.entity,
              value: user.entity!,
            ),

          if (user.code != null && user.code!.isNotEmpty)
            _InfoRow(
              icon: Icons.badge_outlined,
              label: locale.code,
              value: user.code!,
            ),
        ],
      ),
    );
  }
}

class _ProfileImage extends StatelessWidget {
  final String? imageUrl;
  const _ProfileImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 100.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.muted,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? ClipOval(
                    child: NetworkImageViewer(imageUrl: imageUrl!, fit: BoxFit.cover),
                  )
                : Icon(Icons.person_rounded, size: 50.sp, color: AppColors.primary),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: AppColors.secondaryText, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  color: AppColors.secondaryText,
                  height: 1.1,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
