import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/survey_behavior_manager.dart';
import 'survey_navigation_event.dart';
import 'survey_navigation_state.dart';

export 'survey_navigation_event.dart';
export 'survey_navigation_state.dart';

class SurveyNavigationBloc
    extends Bloc<SurveyNavigationEvent, SurveyNavigationState> {
  SurveyNavigationBloc() : super(SurveyNavigationInitial()) {
    on<SetSurvey>(_onSetSurvey);
    on<UpdateResponseId>(_onUpdateResponseId);
    on<ResumeFromSection>(_onResumeFromSection);
    on<RefreshBehavior>(_onRefreshBehavior);
    on<NextSection>(_onNextSection);
    on<PreviousSection>(_onPreviousSection);
    on<GoToSection>(_onGoToSection);
    on<StartSurvey>(_onStartSurvey);
    on<CompleteSurvey>(_onCompleteSurvey);
  }

  void _onSetSurvey(SetSurvey event, Emitter<SurveyNavigationState> emit) {
    int firstVisibleIndex = 0;
    if (event.survey.sections != null) {
      for (int i = 0; i < event.survey.sections!.length; i++) {
        // Initially visibility maps are empty, but we check if we should skip
        // If we want to support initial visibility from saved answers,
        // we might need to call _calculateInitialBehavior
        break;
      }
    }

    emit(
      SurveyNavigationUpdated(
        survey: event.survey,
        responseId: event.responseId,
        currentSectionIndex: firstVisibleIndex,
      ),
    );
  }

  void _onUpdateResponseId(
    UpdateResponseId event,
    Emitter<SurveyNavigationState> emit,
  ) {
    emit(
      SurveyNavigationUpdated(
        survey: state.survey,
        responseId: event.responseId,
        currentSectionIndex: state.currentSectionIndex,
        visibilityMap: state.visibilityMap,
        requirementMap: state.requirementMap,
        currentStep: state.currentStep,
      ),
    );
  }

  void _onResumeFromSection(
    ResumeFromSection event,
    Emitter<SurveyNavigationState> emit,
  ) {
    final survey = state.survey;
    if (survey != null && survey.sections != null) {
      final index = survey.sections!.indexWhere((s) => s.id == event.sectionId);
      if (index != -1) {
        emit(
          SurveyNavigationUpdated(
            survey: survey,
            responseId: state.responseId,
            currentSectionIndex: index,
            visibilityMap: state.visibilityMap,
            requirementMap: state.requirementMap,
            currentStep: SurveyStep.survey,
          ),
        );
      }
    }
  }

  void _onStartSurvey(StartSurvey event, Emitter<SurveyNavigationState> emit) {
    emit(
      SurveyNavigationUpdated(
        survey: state.survey,
        responseId: state.responseId,
        currentSectionIndex: state.currentSectionIndex,
        visibilityMap: state.visibilityMap,
        requirementMap: state.requirementMap,
        currentStep: SurveyStep.survey,
      ),
    );
  }

  void _onCompleteSurvey(
    CompleteSurvey event,
    Emitter<SurveyNavigationState> emit,
  ) {
    emit(
      SurveyNavigationUpdated(
        survey: state.survey,
        responseId: state.responseId,
        currentSectionIndex: state.currentSectionIndex,
        visibilityMap: state.visibilityMap,
        requirementMap: state.requirementMap,
        currentStep: SurveyStep.completion,
      ),
    );
  }

  void _onRefreshBehavior(
    RefreshBehavior event,
    Emitter<SurveyNavigationState> emit,
  ) {
    final survey = state.survey;
    if (survey == null) return;

    final behavior = SurveyBehaviorManager.calculateBehavior(
      logics: survey.conditionalLogics ?? [],
      answers: event.answers,
    );

    emit(
      SurveyNavigationUpdated(
        survey: survey,
        responseId: state.responseId,
        currentSectionIndex: state.currentSectionIndex,
        visibilityMap: Map<String, bool>.from(behavior['visibility'] ?? {}),
        requirementMap: Map<String, bool>.from(behavior['requirement'] ?? {}),
        currentStep: state.currentStep,
      ),
    );
  }

  void _onNextSection(NextSection event, Emitter<SurveyNavigationState> emit) {
    final survey = state.survey;
    if (survey != null && survey.sections != null) {
      int nextIndex = state.currentSectionIndex + 1;
      while (nextIndex < survey.sections!.length) {
        final section = survey.sections![nextIndex];
        if (state.isVisible("section_${section.id}")) {
          emit(
            SurveyNavigationUpdated(
              survey: survey,
              responseId: state.responseId,
              currentSectionIndex: nextIndex,
              visibilityMap: state.visibilityMap,
              requirementMap: state.requirementMap,
              currentStep: state.currentStep,
            ),
          );
          return;
        }
        nextIndex++;
      }
    }
  }

  void _onPreviousSection(
    PreviousSection event,
    Emitter<SurveyNavigationState> emit,
  ) {
    final survey = state.survey;
    if (survey != null && survey.sections != null) {
      int prevIndex = state.currentSectionIndex - 1;
      while (prevIndex >= 0) {
        final section = survey.sections![prevIndex];
        if (state.isVisible("section_${section.id}")) {
          emit(
            SurveyNavigationUpdated(
              survey: survey,
              responseId: state.responseId,
              currentSectionIndex: prevIndex,
              visibilityMap: state.visibilityMap,
              requirementMap: state.requirementMap,
              currentStep: state.currentStep,
            ),
          );
          return;
        }
        prevIndex--;
      }
    }
  }

  void _onGoToSection(GoToSection event, Emitter<SurveyNavigationState> emit) {
    final survey = state.survey;
    if (survey != null && survey.sections != null) {
      if (event.index >= 0 && event.index < survey.sections!.length) {
        final section = survey.sections![event.index];
        // If target section is hidden, don't go there
        if (!state.isVisible("section_${section.id}")) return;

        emit(
          SurveyNavigationUpdated(
            survey: survey,
            responseId: state.responseId,
            currentSectionIndex: event.index,
            visibilityMap: state.visibilityMap,
            requirementMap: state.requirementMap,
            currentStep: state.currentStep,
          ),
        );
      }
    }
  }
}
