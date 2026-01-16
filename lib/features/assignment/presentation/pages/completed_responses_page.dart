import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../responses/bloc/responses_list/responses_list_bloc.dart';
import '../../../responses/models/response_status.dart';
import '../widgets/completed_response_card.dart';
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
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
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
              // Filter only completed (submitted) responses
              final completedResponses = state.responses
                  .where((r) => r.status == ResponseStatus.submitted)
                  .toList();

              if (completedResponses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: AppColors.secondaryText.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        s.no_responses_found,
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 16,
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
                  itemCount: completedResponses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final response = completedResponses[index];
                    return CompletedResponseCard(
                      response: response,
                      onTap: () {
                        context.push(
                          Routes.completedResponseViewPath,
                          extra: {'responseId': response.id},
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
