import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/assignments_list/assignments_list_bloc.dart';
import '../../bloc/survey_navigation/survey_navigation_bloc.dart';
import '../../bloc/save_section/save_section_bloc.dart';
import '../../repository/assignment_local_repository.dart';
import '../widgets/survey_intro_widget.dart';
import '../widgets/survey_completion_widget.dart';
import '../widgets/survey_section_widget.dart';

import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/unified_snackbar.dart';
import '../widgets/demographics_dialog.dart';

import '../../../../core/enums/survey_enums.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../device_location/service/location_service.dart';
import '../../bloc/start_response/start_response_bloc.dart' as start;

class SurveyAnsweringScreen extends StatelessWidget {
  const SurveyAnsweringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SurveyNavigationBloc, SurveyNavigationState>(
          listenWhen: (prev, curr) =>
              prev.currentStep != curr.currentStep &&
              curr.currentStep == SurveyStep.completion,
          listener: (context, state) async {
            // Ensure local storage reflects completion when moving to completion step
            if (state.responseId != null && state.survey != null) {
              final surveyId = state.survey!.id;
              final responseId = state.responseId!;

              await AssignmentLocalRepository.addCompletedResponse(
                surveyId,
                responseId,
              );
              await AssignmentLocalRepository.unlinkResponseFromSurvey(
                surveyId,
                responseId,
              );
              await AssignmentLocalRepository.removeResponseDraft(responseId);
            }
            context.read<AssignmentsListBloc>().add(LoadAssignments());
          },
        ),
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
              final answers = state.saveRequest?.answers ?? [];
              final answersMap = {for (var a in answers) a.questionId: a.value};

              if (state.response.isComplete) {
                navBloc.add(CompleteSurvey());
                context.read<AssignmentsListBloc>().add(LoadAssignments());
              } else {
                navBloc.add(NextSection(answers: answersMap));
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
          onStart: () async {
            if (state.responseId == null) {
              // Show demographics dialog to collect required data
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                barrierDismissible: false,
                builder: (context) => const DemographicsDialog(),
              );

              if (result != null && context.mounted) {
                final gender = result['gender'] as Gender;
                final ageGroup = result['ageGroup'] as AgeGroup;
                Map<String, double>? locationMap;

                if (state.survey!.gpsRequired == true) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => PopScope(
                      canPop: false,
                      child: AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const LoadingWidget(),
                            SizedBox(height: 16),
                            Text(S.of(context).getting_location),
                          ],
                        ),
                      ),
                    ),
                  );
                  try {
                    final deviceLocation =
                        await LocationService.getCurrentLocation();
                    if (!context.mounted) return;
                    Navigator.of(context).pop(context);
                    locationMap = {
                      'latitude': deviceLocation.latitude,
                      'longitude': deviceLocation.longitude,
                    };
                  } catch (_) {
                    if (context.mounted) {
                      Navigator.of(context).pop(context);
                      UnifiedSnackbar.error(
                        context,
                        message: S.of(context).location_required,
                      );
                    }
                    return;
                  }
                }

                context.read<start.StartResponseBloc>().add(
                  start.UpdateSurveyId(state.survey!.id),
                );
                context.read<start.StartResponseBloc>().add(
                  start.UpdateGender(gender),
                );
                context.read<start.StartResponseBloc>().add(
                  start.UpdateAgeGroup(ageGroup),
                );
                if (locationMap != null) {
                  context.read<start.StartResponseBloc>().add(
                    start.UpdateLocation(locationMap),
                  );
                }
                context.read<start.StartResponseBloc>().add(
                  start.StartSurveyResponse(),
                );
              }
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
