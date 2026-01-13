import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/unified_snackbar.dart';
import '../../bloc/assignments_list/assignments_list_bloc.dart';
import '../../bloc/start_response/start_response_bloc.dart';
import '../widgets/assignment_card.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<StartResponseBloc, StartResponseState>(
          listener: (context, state) {
            if (state is StartResponseSuccess) {
              UnifiedSnackbar.success(context, message: s.new_response_success);
              // Refresh the list to show the new local response ID
              context.read<AssignmentsListBloc>().add(LoadAssignments());

              // TODO: Navigate to the survey taking screen with the new response ID
              // context.push(Routes.surveyDetailsPath, extra: state.response.response.id);
            } else if (state is StartResponseError) {
              UnifiedSnackbar.error(
                context,
                message: s.error_with_message(state.message),
              );
            }
          },
        ),
      ],
      child: Scaffold(
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
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      s.error_occurred,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.secondaryText),
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
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: surveys.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return AssignmentCard(survey: surveys[index]);
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
