import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../models/researcher_profile_response_model.dart';

class SupervisorInfoCard extends StatelessWidget {
  final SupervisorModel? supervisor;

  const SupervisorInfoCard({super.key, required this.supervisor});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

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
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.supervisor_account_rounded,
                color: AppColors.primary,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Text(
                locale.supervisor,
                style: TextStyle(
                  fontSize: context.adaptiveFont(16.sp),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (supervisor != null) ...[
            _buildInfoRow(context, Icons.person, supervisor!.name),
            SizedBox(height: 8.h),
            _buildInfoRow(context, Icons.email, supervisor!.email),
            if (supervisor!.mobile != null) ...[
              SizedBox(height: 8.h),
              _buildInfoRow(context, Icons.phone, supervisor!.mobile!),
            ],
          ] else ...[
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text(
                  locale.noSupervisorAssigned,
                  style: TextStyle(
                    fontSize: context.adaptiveFont(14.sp),
                    color: AppColors.secondaryText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondaryText, size: 16.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: context.adaptiveFont(14.sp),
              color: AppColors.primaryText,
            ),
          ),
        ),
      ],
    );
  }
}
