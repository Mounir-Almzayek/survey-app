import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/models/survey/survey_model.dart';
import '../../../../core/widgets/unified_snackbar.dart';
import '../../bloc/assignments_list/assignments_list_bloc.dart';
import '../../bloc/survey_navigation/survey_navigation_bloc.dart' as nav;
import '../../bloc/save_section/save_section_bloc.dart' as save;
import '../../bloc/start_response/start_response_bloc.dart' as start;
import '../../../device_location/bloc/device_location/device_location_bloc.dart';
import '../../../device_location/bloc/device_location/device_location_event.dart';
import '../screens/survey_answering_screen.dart';

class SurveyAnsweringPage extends StatelessWidget {
  final Survey survey;
  final int? responseId;

  const SurveyAnsweringPage({super.key, required this.survey, this.responseId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              nav.SurveyNavigationBloc()
                ..add(nav.SetSurvey(survey, responseId)),
        ),
        BlocProvider(
          create: (context) =>
              save.SaveSectionBloc()..add(save.UpdateResponseId(responseId)),
        ),
        BlocProvider(create: (context) => start.StartResponseBloc()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<save.SaveSectionBloc, save.SaveSectionState>(
            listenWhen: (prev, curr) =>
                prev.saveRequest == null && curr.saveRequest != null,
            listener: (context, state) {
              final lastSectionId = state.saveRequest?.lastReachedSectionId;
              final answers = state.saveRequest?.answers ?? [];

              // 1. Resume from the last reached section if available
              if (lastSectionId != null && lastSectionId != 0) {
                context.read<nav.SurveyNavigationBloc>().add(
                  nav.ResumeFromSection(lastSectionId),
                );
              }

              // 2. Sync previous answers to Refresh Behavior immediately
              if (answers.isNotEmpty) {
                final answersMap = {
                  for (var a in answers) a.questionId: a.value,
                };
                context.read<nav.SurveyNavigationBloc>().add(
                  nav.RefreshBehavior(answersMap),
                );
              }
            },
          ),
          BlocListener<start.StartResponseBloc, start.StartResponseState>(
            listenWhen: (prev, curr) =>
                curr is start.StartResponseError ||
                (curr is start.StartResponseSuccess &&
                    prev is! start.StartResponseSuccess),
            listener: (context, state) {
              if (state is start.StartResponseError) {
                final message = state.isMaxResponsesReached
                    ? S.of(context).survey_max_responses_reached
                    : state.isDemographicQuotaFull
                    ? S.of(context).demographic_quota_full_for_category
                    : state.message;
                UnifiedSnackbar.error(context, message: message);
                return;
              }
              if (state is start.StartResponseSuccess) {
                final newId = state.response.response.id;
                final navBloc = context.read<nav.SurveyNavigationBloc>();
                final saveBloc = context.read<save.SaveSectionBloc>();

                // 1. Update navigation with new ID
                navBloc.add(nav.UpdateResponseId(newId));

                // 2. CRITICAL: Update SaveBloc with new ID AND the current section ID
                // to avoid section_id: 0
                final currentSectionId = navBloc.state.currentSection?.id;
                saveBloc.add(
                  save.UpdateResponseId(
                    newId,
                    initialSectionId: currentSectionId,
                  ),
                );

                // 3. Move to the survey steps
                navBloc.add(nav.StartSurvey());

                // 4. Refresh assignments list so UI stays in sync
                context.read<AssignmentsListBloc>().add(LoadAssignments());

                // 5. Start location tracking if waiting for context (first start) or refresh assignment_id (new survey)
                context.read<DeviceLocationBloc>().add(
                  const StartLocationTrackingEvent(),
                );
              }
            },
          ),
        ],
        child: const SurveyAnsweringScreen(),
      ),
    );
  }
}
