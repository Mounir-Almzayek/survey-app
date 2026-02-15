import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/styles/app_colors.dart';
import '../../../../../core/utils/responsive_layout.dart';

class DatesInfoSection extends StatelessWidget {
  final DateTime? createdAt;
  final DateTime? availabilityStartAt;
  final DateTime? availabilityEndAt;
  final DateTime? updatedAt;

  const DatesInfoSection({
    super.key,
    required this.createdAt,
    required this.availabilityStartAt,
    required this.availabilityEndAt,
    required this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd');
    final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          if (createdAt != null)
            _buildDateRow(
              context,
              Icons.calendar_today_outlined,
              s.created_at_colon(dateFormat.format(createdAt!)),
            ),
          if (availabilityStartAt != null || availabilityEndAt != null)
            _buildDateRow(
              context,
              Icons.access_time_rounded,
              s.availability_period(
                availabilityStartAt != null
                    ? dateFormat.format(availabilityStartAt!)
                    : '...',
                availabilityEndAt != null
                    ? dateFormat.format(availabilityEndAt!)
                    : '...',
              ),
            ),
          if (updatedAt != null)
            _buildDateRow(
              context,
              Icons.update_rounded,
              s.last_update(dateTimeFormat.format(updatedAt!)),
            ),
        ],
      ),
    );
  }

  Widget _buildDateRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: context.adaptiveFont(12).sp,
            color: AppColors.secondaryText.withValues(alpha: 0.6),
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: context.adaptiveFont(9).sp,
              color: AppColors.secondaryText.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
