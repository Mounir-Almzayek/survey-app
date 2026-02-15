import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../bloc/assignments_list/assignments_list_bloc.dart';
import '../widgets/assignment_card.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<AssignmentsListBloc, AssignmentsListState>(
        builder: (context, state) {
          if (state is AssignmentsListLoading) {
            return const LoadingWidget();
          }

          if (state is AssignmentsListError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () =>
                  context.read<AssignmentsListBloc>().add(LoadAssignments()),
            );
          }

          if (state is AssignmentsListLoaded) {
            final surveys = state.response.surveys;

            if (surveys.isEmpty) {
              return Center(child: Text(s.no_surveys_available));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AssignmentsListBloc>().add(LoadAssignments());
              },
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.responsive(
                      1.sw,
                      tablet: 600.w,
                      desktop: 800.w,
                    ),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.all(
                      context.responsive(16.r, tablet: 24.r, desktop: 32.r),
                    ),
                    itemCount:
                        surveys.length + 1, // Add 1 for the bottom spacing
                    separatorBuilder: (context, index) {
                      // Don't add separator after the last actual item
                      if (index == surveys.length - 1)
                        return const SizedBox.shrink();
                      return SizedBox(
                        height: context.responsive(
                          12.h,
                          tablet: 16.h,
                          desktop: 20.h,
                        ),
                      );
                    },
                    itemBuilder: (context, index) {
                      // Last item is the bottom spacing
                      if (index == surveys.length) {
                        return SizedBox(
                          height: context.responsive(
                            100.h, // Space for floating bottom bar on mobile
                            tablet: 120.h,
                            desktop: 140.h,
                          ),
                        );
                      }
                      return AssignmentCard(survey: surveys[index]);
                    },
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
