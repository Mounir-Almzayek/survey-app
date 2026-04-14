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

  Set<int> _lockedAfterLeavingCurrentSection() {
    return Set<int>.from(state.lockedSectionIndices)
      ..add(state.currentSectionIndex);
  }

  void _onSetSurvey(SetSurvey event, Emitter<SurveyNavigationState> emit) {
    int firstVisibleIndex = 0;
    if (event.survey.sections != null) {
      for (int i = 0; i < event.survey.sections!.length; i++) {
        final section = event.survey.sections![i];
        // Note: At this point visibilityMap is empty, so all are visible by default.
        // But if we ever add default hidden logic, this is where it starts.
        if (state.isVisible("section_${section.id}")) {
          firstVisibleIndex = i;
          break;
        }
      }
    }

    emit(
      SurveyNavigationUpdated(
        survey: event.survey,
        responseId: event.responseId,
        currentSectionIndex: firstVisibleIndex,
        lockedSectionIndices: const {},
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
        jumpMap: state.jumpMap,
        currentStep: state.currentStep,
        lockedSectionIndices: state.lockedSectionIndices,
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
        final merged = Set<int>.from(state.lockedSectionIndices);
        for (var i = 0; i < index; i++) {
          merged.add(i);
        }
        emit(
          SurveyNavigationUpdated(
            survey: survey,
            responseId: state.responseId,
            currentSectionIndex: index,
            visibilityMap: state.visibilityMap,
            requirementMap: state.requirementMap,
            jumpMap: state.jumpMap,
            currentStep: SurveyStep.survey,
            lockedSectionIndices: merged,
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
        jumpMap: state.jumpMap,
        currentStep: SurveyStep.survey,
        lockedSectionIndices: state.lockedSectionIndices,
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
        jumpMap: state.jumpMap,
        currentStep: SurveyStep.completion,
        lockedSectionIndices: state.lockedSectionIndices,
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
        jumpMap: Map<int, int>.from(behavior['jump'] ?? {}),
        currentStep: state.currentStep,
        lockedSectionIndices: state.lockedSectionIndices,
      ),
    );
  }

  void _onNextSection(NextSection event, Emitter<SurveyNavigationState> emit) {
    final survey = state.survey;
    if (survey != null && survey.sections != null) {
      // 1. If answers provided, recalculate behavior first to ensure current state is up-to-date
      Map<String, bool> currentVisibility = state.visibilityMap;
      Map<int, int> currentJumpMap = state.jumpMap;

      if (event.answers != null) {
        final behavior = SurveyBehaviorManager.calculateBehavior(
          logics: survey.conditionalLogics ?? [],
          answers: event.answers!,
        );
        currentVisibility = Map<String, bool>.from(
          behavior['visibility'] ?? {},
        );
        currentJumpMap = Map<int, int>.from(behavior['jump'] ?? {});
      }

      final section = state.currentSection;
      if (section == null) return;

      final locked = _lockedAfterLeavingCurrentSection();

      // 2. Check for Jump logic using the latest jump map
      // Check for jump from any question that was just answered
      int? jumpTargetId;

      // First, check if any question in the current section triggers a jump
      if (section.questions != null) {
        for (final question in section.questions!) {
          final targetId = currentJumpMap[question.id];
          if (targetId != null) {
            jumpTargetId = targetId;
            break;
          }
        }
      }

      // If no jump found in current section, check if any answered question triggers a jump
      if (jumpTargetId == null && event.answers != null) {
        for (final answeredQuestionId in event.answers!.keys) {
          final targetId = currentJumpMap[answeredQuestionId];
          if (targetId != null) {
            jumpTargetId = targetId;
            break;
          }
        }
      }

      if (jumpTargetId != null) {
        // Check if jumpTargetId is a section ID or question ID
        // First, try to find it as a section ID
        final targetIndex = survey.sections!.indexWhere(
          (s) => s.id == jumpTargetId,
        );

        if (targetIndex != -1) {
          emit(
            SurveyNavigationUpdated(
              survey: survey,
              responseId: state.responseId,
              currentSectionIndex: targetIndex,
              visibilityMap: currentVisibility,
              requirementMap: state.requirementMap,
              jumpMap: currentJumpMap,
              currentStep: state.currentStep,
              lockedSectionIndices: locked,
            ),
          );
          return;
        }

        // If not found as section ID, try to find the section that contains the target question
        int? targetSectionId;
        for (final section in survey.sections!) {
          if (section.questions != null) {
            for (final question in section.questions!) {
              if (question.id == jumpTargetId) {
                targetSectionId = section.id;
                break;
              }
            }
            if (targetSectionId != null) break;
          }
        }

        if (targetSectionId != null) {
          final targetIndex = survey.sections!.indexWhere(
            (s) => s.id == targetSectionId,
          );
          if (targetIndex != -1) {
            emit(
              SurveyNavigationUpdated(
                survey: survey,
                responseId: state.responseId,
                currentSectionIndex: targetIndex,
                visibilityMap: currentVisibility,
                requirementMap: state.requirementMap,
                jumpMap: currentJumpMap,
                currentStep: state.currentStep,
                lockedSectionIndices: locked,
              ),
            );
            return;
          }
        }
      }

      // 3. Find next visible section
      int nextIndex = state.currentSectionIndex + 1;
      bool foundNext = false;
      while (nextIndex < survey.sections!.length) {
        final section = survey.sections![nextIndex];
        final bool isSectionVisible =
            currentVisibility["section_${section.id}"] ?? true;

        if (isSectionVisible) {
          emit(
            SurveyNavigationUpdated(
              survey: survey,
              responseId: state.responseId,
              currentSectionIndex: nextIndex,
              visibilityMap: currentVisibility,
              requirementMap: state.requirementMap,
              jumpMap: currentJumpMap,
              currentStep: state.currentStep,
              lockedSectionIndices: locked,
            ),
          );
          foundNext = true;
          break;
        }
        nextIndex++;
      }

      // 4. Fallback: If no next section found, trigger completion
      if (!foundNext) {
        emit(
          SurveyNavigationUpdated(
            survey: survey,
            responseId: state.responseId,
            currentSectionIndex: state.currentSectionIndex,
            visibilityMap: currentVisibility,
            requirementMap: state.requirementMap,
            jumpMap: currentJumpMap,
            currentStep: state.currentStep,
            lockedSectionIndices: locked,
          ),
        );
        add(CompleteSurvey());
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
              jumpMap: state.jumpMap,
              currentStep: state.currentStep,
              lockedSectionIndices: state.lockedSectionIndices,
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
            jumpMap: state.jumpMap,
            currentStep: state.currentStep,
            lockedSectionIndices: state.lockedSectionIndices,
          ),
        );
      }
    }
  }
}
