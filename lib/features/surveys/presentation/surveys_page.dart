import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/styles/app_colors.dart';
import '../../surveys/bloc/assigned_surveys/assigned_surveys_bloc.dart';
import '../../surveys/bloc/assigned_surveys/assigned_surveys_event.dart';
import '../../surveys/bloc/assigned_surveys/assigned_surveys_state.dart';
import 'widgets/survey_card.dart';

class SurveysPage extends StatelessWidget {
  const SurveysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AssignedSurveysBloc()..add(LoadAssignedSurveys()),
      child: Scaffold(
        backgroundColor: Color(0xFFF8FAFC), // Light slate background
        body: BlocBuilder<AssignedSurveysBloc, AssignedSurveysState>(
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.h,
                  floating: false,
                  pinned: true,
                  backgroundColor: Color(0xFFF8FAFC),
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.only(left: 20.w, bottom: 16.h),
                    title: Text(
                      'Assigned\nSurveys',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    centerTitle: false,
                  ),
                ),
                if (state is AssignedSurveysLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (state is AssignedSurveysError)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48.sp,
                            color: Colors.red[300],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            state.message,
                            style: TextStyle(color: AppColors.secondaryText),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<AssignedSurveysBloc>().add(
                                RefreshAssignedSurveys(),
                              );
                            },
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state is AssignedSurveysLoaded)
                  if (state.surveys.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 60.sp,
                              color: AppColors.muted,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              "No surveys assigned yet",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.only(
                        bottom: 100.h,
                      ), // Space for fab usually
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final survey = state.surveys[index];
                          return SurveyCard(
                            survey: survey,
                            index: index,
                            onTap: () {
                              // Navigate to survey details
                            },
                          );
                        }, childCount: state.surveys.length),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}
