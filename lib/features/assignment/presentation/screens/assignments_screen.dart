import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: context.adaptiveIcon(50.sp),
                    color: AppColors.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    s.error_occurred,
                    style: TextStyle(
                      fontSize: context.adaptiveFont(16.sp),
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: context.adaptiveFont(12.sp),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.read<AssignmentsListBloc>().add(
                      LoadAssignments(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(s.retry),
                  ),
                ],
              ),
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
                    itemCount: surveys.length,
                    separatorBuilder: (context, index) => SizedBox(
                      height: context.responsive(
                        12.h,
                        tablet: 16.h,
                        desktop: 20.h,
                      ),
                    ),
                    itemBuilder: (context, index) {
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
