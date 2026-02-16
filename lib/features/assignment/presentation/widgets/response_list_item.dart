import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../bloc/assignments_list/assignments_list_bloc.dart';

import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';

class ResponseListItem extends StatelessWidget {
  final int responseId;
  final int surveyId;

  const ResponseListItem({
    super.key,
    required this.responseId,
    required this.surveyId,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: context.adaptiveIcon(18.sp),
            color: AppColors.secondaryText,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              s.response_number(responseId),
              style: TextStyle(
                fontSize: context.adaptiveFont(13.sp),
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ),
          _buildActionButton(
            context,
            label: s.resume_survey,
            icon: Icons.play_arrow_rounded,
            color: AppColors.primary,
            onPressed: () {
              final assignmentsState = context
                  .read<AssignmentsListBloc>()
                  .state;
              if (assignmentsState is AssignmentsListLoaded) {
                final survey = assignmentsState.response.surveys.firstWhere(
                  (s) => s.id == surveyId,
                );
                context.push(
                  Routes.surveyAnsweringPath,
                  extra: {'survey': survey, 'responseId': responseId},
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: context.adaptiveIcon(14.sp), color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: context.adaptiveFont(10.sp),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
