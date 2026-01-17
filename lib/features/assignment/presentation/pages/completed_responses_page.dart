import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_layout.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../responses/bloc/responses_list/responses_list_bloc.dart';
import '../widgets/response_id_card.dart';
import '../../../../core/widgets/loading_widget.dart';

class CompletedResponsesPage extends StatelessWidget {
  final int surveyId;

  const CompletedResponsesPage({super.key, required this.surveyId});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider(
      create: (context) =>
          ResponsesListBloc()..add(LoadResponsesForSurvey(surveyId: surveyId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Completed Responses'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<ResponsesListBloc, ResponsesListState>(
          builder: (context, state) {
            if (state is ResponsesListLoading) {
              return const Center(child: LoadingWidget());
            }

            if (state is ResponsesListError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: context.adaptiveIcon(64.sp),
                      color: AppColors.error,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: context.adaptiveFont(14.sp),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ResponsesListBloc>().add(
                          LoadResponsesForSurvey(
                            surveyId: surveyId,
                            forceRefresh: true,
                          ),
                        );
                      },
                      child: Text(s.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is ResponsesListLoaded) {
              final completedResponseIds = state.responseIds;

              if (completedResponseIds.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: context.adaptiveIcon(64.sp),
                        color: AppColors.secondaryText.withOpacity(0.5),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        s.no_responses_found,
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: context.adaptiveFont(16.sp),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ResponsesListBloc>().add(
                    LoadResponsesForSurvey(
                      surveyId: surveyId,
                      forceRefresh: true,
                    ),
                  );
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: completedResponseIds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final responseId = completedResponseIds[index];
                    return ResponseIdCard(
                      responseId: responseId,
                      onTap: () {
                        context.push(
                          Routes.completedResponseViewPath,
                          extra: {'responseId': responseId},
                        );
                      },
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
