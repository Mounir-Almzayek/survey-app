import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        color: AppColors.brightWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          _ProfileImage(imageUrl: imageUrl),
          SizedBox(height: 16.h),
          Text(
            user.name,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            user.email,
            style: TextStyle(fontSize: 16.sp, color: AppColors.textGrey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          const Divider(color: AppColors.border, height: 1),
          SizedBox(height: 24.h),
          if (user.phone != null && user.phone!.isNotEmpty) ...[
            _InfoRow(label: locale.phone, value: user.phone!),
            SizedBox(height: 16.h),
          ],
          if (user.company != null && user.company!.isNotEmpty) ...[
            _InfoRow(label: locale.company, value: user.company!),
            SizedBox(height: 16.h),
          ],
          if (user.position != null && user.position!.isNotEmpty) ...[
            _InfoRow(label: locale.position, value: user.position!),
            SizedBox(height: 16.h),
          ],
          if (user.entity != null && user.entity!.isNotEmpty) ...[
            _InfoRow(label: locale.entity, value: user.entity!),
            SizedBox(height: 16.h),
          ],
          if (user.code != null && user.code!.isNotEmpty) ...[
            _InfoRow(label: locale.code, value: user.code!),
            SizedBox(height: 16.h),
          ],
          if (user.nationality != null && user.nationality!.isNotEmpty) ...[
            _InfoRow(label: locale.nationality, value: user.nationality!),
            SizedBox(height: 16.h),
          ],
          if (user.idNo != null && user.idNo!.isNotEmpty) ...[
            _InfoRow(label: locale.id_number, value: user.idNo!),
            SizedBox(height: 16.h),
          ],
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
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkWhite,
        border: Border.all(color: AppColors.primary, width: 3),
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipOval(
              child: NetworkImageViewer(imageUrl: imageUrl!, fit: BoxFit.cover),
            )
          : Icon(Icons.person, size: 60.sp, color: AppColors.primary),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.primaryText,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
