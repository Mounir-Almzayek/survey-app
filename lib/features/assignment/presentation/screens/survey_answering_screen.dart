import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/survey_navigation/survey_navigation_bloc.dart';
import '../../bloc/save_section/save_section_bloc.dart';
import '../../repository/assignment_local_repository.dart';
import '../widgets/survey_intro_widget.dart';
import '../widgets/survey_completion_widget.dart';
import '../widgets/survey_section_widget.dart';

import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/unified_snackbar.dart';

import '../../bloc/start_response/start_response_bloc.dart' as start;

class SurveyAnsweringScreen extends StatelessWidget {
  const SurveyAnsweringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SaveSectionBloc, SaveSectionState>(
          listener: (context, state) async {
            if (state is SaveSectionInitial && state.saveRequest != null) {
              // Refresh behavior when a draft is loaded (Resume scenario)
              final answers = state.saveRequest?.answers ?? [];
              final answersMap = {for (var a in answers) a.questionId: a.value};
              context.read<SurveyNavigationBloc>().add(
                RefreshBehavior(answersMap),
              );
            }

            if (state is SaveSectionSuccess) {
              final navBloc = context.read<SurveyNavigationBloc>();
              final isLastSection = navBloc.state.isLastSection;

              if (state.response.isComplete || isLastSection) {
                // 1. Store as completed locally
                if (state.responseId != null && navBloc.state.survey != null) {
                  final surveyId = navBloc.state.survey!.id;
                  final responseId = state.responseId!;

                  await AssignmentLocalRepository.addCompletedResponse(
                    surveyId,
                    responseId,
                  );

                  // 2. Remove from local drafts/responses list
                  await AssignmentLocalRepository.unlinkResponseFromSurvey(
                    surveyId,
                    responseId,
                  );
                  await AssignmentLocalRepository.removeResponseDraft(
                    responseId,
                  );
                }

                // Move to completion step
                navBloc.add(CompleteSurvey());
              } else {
                // If section saved successfully and not complete, move to next
                navBloc.add(NextSection());
              }
            } else if (state is SaveSectionError) {
              UnifiedSnackbar.error(context, message: state.message);
            }
          },
        ),
      ],
      child: BlocBuilder<SurveyNavigationBloc, SurveyNavigationState>(
        builder: (context, navState) {
          if (navState.survey == null) {
            return const Scaffold(body: Center(child: LoadingWidget()));
          }

          return BlocBuilder<start.StartResponseBloc, start.StartResponseState>(
            builder: (context, startState) {
              final currentStep = navState.currentStep;
              final isLoading = startState is start.StartResponseLoading;

              return Scaffold(
                body: _buildStepContent(
                  context,
                  currentStep,
                  navState,
                  isLoading,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    SurveyStep step,
    SurveyNavigationState state,
    bool isLoading,
  ) {
    switch (step) {
      case SurveyStep.intro:
        return SurveyIntroWidget(
          survey: state.survey!,
          isLoading: isLoading,
          onStart: () {
            if (state.responseId == null) {
              // Trigger starting a new response online/offline
              context.read<start.StartResponseBloc>().add(
                start.UpdateSurveyId(state.survey!.id),
              );
              context.read<start.StartResponseBloc>().add(
                start.StartSurveyResponse(),
              );
            } else {
              // Already have an ID (resume), just move forward
              context.read<SurveyNavigationBloc>().add(StartSurvey());
            }
          },
        );
      case SurveyStep.survey:
        return const SurveySectionWidget();
      case SurveyStep.completion:
        return SurveyCompletionWidget(survey: state.survey!);
    }
  }
}
