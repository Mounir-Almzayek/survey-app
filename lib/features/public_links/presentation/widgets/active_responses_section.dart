import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../bloc/active_responses/active_responses_bloc.dart';
import '../../bloc/active_responses/active_responses_event.dart';
import '../../bloc/active_responses/active_responses_state.dart';
import '../../models/public_link_active_response.dart';
import 'active_response_card.dart';
import 'active_responses_stats.dart';

class ActiveResponsesSection extends StatefulWidget {
  const ActiveResponsesSection({super.key});

  @override
  State<ActiveResponsesSection> createState() => _ActiveResponsesSectionState();
}

class _ActiveResponsesSectionState extends State<ActiveResponsesSection> {
  bool _isExpanded = false; // Collapsed by default to show only stats

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<ActiveResponsesBloc, ActiveResponsesState>(
      builder: (context, state) {
        if (state is ActiveResponsesSuccess && state.responses.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.only(bottom: 24.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 1. Statistics Part - Always Visible
              if (state is ActiveResponsesSuccess)
                ActiveResponsesStats(responses: state.responses),

              if (state is ActiveResponsesLoading)
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: const Center(child: LoadingWidget()),
                ),

              // 2. Expand/Collapse Header
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.muted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(_isExpanded ? 0 : 16.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isExpanded ? s.hide_details : s.view_survey_drafts,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18.sp,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),

              // 3. List Part - Collapsible
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [
                      if (state is ActiveResponsesError)
                        ErrorStateWidget(
                          message: state.message,
                          onRetry: () {
                            context.read<ActiveResponsesBloc>().add(
                              LoadActiveResponses(),
                            );
                          },
                        ),
                      if (state is ActiveResponsesSuccess)
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.responses.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            final response = state.responses[index];
                            return ActiveResponseCard(
                              response: response,
                              onDelete: () => _confirmDelete(context, response),
                              onResume: () {
                                // To be implemented later
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, PublicLinkActiveResponse response) {
    final s = S.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.delete_draft_title),
        content: Text(s.delete_draft_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<ActiveResponsesBloc>().add(
                RemoveActiveResponse(response.shortCode),
              );
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              s.delete,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
