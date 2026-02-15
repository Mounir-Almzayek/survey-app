import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/styles/app_colors.dart';
import '../../../../../core/utils/responsive_layout.dart';
import '../../../../core/enums/survey_enums.dart';

class StatusChip extends StatelessWidget {
  final SurveyStatus? status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status!.name.toUpperCase(),
        style: TextStyle(
          fontSize: context.adaptiveFont(9).sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
