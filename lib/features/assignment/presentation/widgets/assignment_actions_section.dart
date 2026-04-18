import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/models/survey/survey_model.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/unified_snackbar.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../public_links/bloc/create_short_lived_link/create_short_lived_link_bloc.dart';
import '../../../public_links/bloc/create_short_lived_link/create_short_lived_link_state.dart';
import 'short_link_config_dialog.dart';

class AssignmentActionsSection extends StatelessWidget {
  final Survey survey;

  const AssignmentActionsSection({super.key, required this.survey});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.play_circle_outline_rounded,
                label: s.new_response,
                onTap: () {
                  if (survey.hasReachedMaxResponses) {
                    UnifiedSnackbar.error(
                      context,
                      message: s.survey_max_responses_reached,
                    );
                    return;
                  }
                  context.push(
                    Routes.surveyAnsweringPath,
                    extra: {'survey': survey, 'responseId': null},
                  );
                },
              ),
            ),
            _VerticalDivider(),
            Expanded(
              child: _ActionButton(
                icon: Icons.history_rounded,
                label: s.view_completed_responses,
                onTap: () {
                  context.push(
                    Routes.completedResponsesPath,
                    extra: {'surveyId': survey.id},
                  );
                },
              ),
            ),
            _VerticalDivider(),
            Expanded(
              child:
                  BlocBuilder<
                    CreateShortLivedLinkBloc,
                    CreateShortLivedLinkState
                  >(
                    builder: (context, state) {
                      return _ActionButton(
                        icon: Icons.link_rounded,
                        label: s.short_lived_link_section,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => BlocProvider.value(
                              value: context.read<CreateShortLivedLinkBloc>(),
                              child: ShortLinkConfigDialog(survey: survey),
                            ),
                          );
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: context.adaptiveIcon(24.sp),
                color: AppColors.primary,
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: context.adaptiveFont(11.sp),
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryText,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24.h,
      width: 1,
      color: AppColors.border.withValues(alpha: 0.3),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
    );
  }
}
