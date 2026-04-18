import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/survey_behavior_manager.dart';
import '../../../../core/utils/survey_jump_entry_helper.dart';
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
        jumpEntryQuestionBySectionId: const {},
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
        jumpEntryQuestionBySectionId: state.jumpEntryQuestionBySectionId,
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
            jumpEntryQuestionBySectionId: state.jumpEntryQuestionBySectionId,
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
        jumpEntryQuestionBySectionId: state.jumpEntryQuestionBySectionId,
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
        jumpEntryQuestionBySectionId: state.jumpEntryQuestionBySectionId,
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

    final jumpMap = Map<int, int>.from(behavior['jump'] ?? {});
    final jumpEntry = SurveyJumpEntryHelper.computeJumpEntryMap(
      survey: survey,
      jumpMap: jumpMap,
    );

    emit(
      SurveyNavigationUpdated(
        survey: survey,
        responseId: state.responseId,
        currentSectionIndex: state.currentSectionIndex,
        visibilityMap: Map<String, bool>.from(behavior['visibility'] ?? {}),
        requirementMap: Map<String, bool>.from(behavior['requirement'] ?? {}),
        jumpMap: jumpMap,
        currentStep: state.currentStep,
        lockedSectionIndices: state.lockedSectionIndices,
        jumpEntryQuestionBySectionId: jumpEntry,
      ),
    );
  }

  void _onNextSection(NextSection event, Emitter<SurveyNavigationState> emit) {
    final survey = state.survey;
    if (survey != null && survey.sections != null) {
      Map<String, bool> currentVisibility = state.visibilityMap;
      Map<String, bool> currentRequirement = state.requirementMap;
      Map<int, int> currentJumpMap = state.jumpMap;

      if (event.answers != null) {
        final behavior = SurveyBehaviorManager.calculateBehavior(
          logics: survey.conditionalLogics ?? [],
          answers: event.answers!,
        );
        currentVisibility = Map<String, bool>.from(
          behavior['visibility'] ?? {},
        );
        currentRequirement = Map<String, bool>.from(
          behavior['requirement'] ?? {},
        );
        currentJumpMap = Map<int, int>.from(behavior['jump'] ?? {});
      }

      final section = state.currentSection;
      if (section == null) return;

      final locked = _lockedAfterLeavingCurrentSection();

      int? jumpTargetId;

      if (section.questions != null) {
        for (final question in section.questions!) {
          final targetId = currentJumpMap[question.id];
          if (targetId != null) {
            jumpTargetId = targetId;
            break;
          }
        }
      }

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
        final targetIndex = survey.sections!.indexWhere(
          (s) => s.id == jumpTargetId,
        );

        if (targetIndex != -1) {
          final destSection = survey.sections![targetIndex];
          final jumpEntry = Map<int, int>.from(
            SurveyJumpEntryHelper.computeJumpEntryMap(
              survey: survey,
              jumpMap: currentJumpMap,
            ),
          )..remove(destSection.id);
          emit(
            SurveyNavigationUpdated(
              survey: survey,
              responseId: state.responseId,
              currentSectionIndex: targetIndex,
              visibilityMap: currentVisibility,
              requirementMap: currentRequirement,
              jumpMap: currentJumpMap,
              currentStep: state.currentStep,
              lockedSectionIndices: locked,
              jumpEntryQuestionBySectionId: jumpEntry,
            ),
          );
          return;
        }

        int? targetSectionId;
        for (final sec in survey.sections!) {
          if (sec.questions != null) {
            for (final question in sec.questions!) {
              if (question.id == jumpTargetId) {
                targetSectionId = sec.id;
                break;
              }
            }
            if (targetSectionId != null) break;
          }
        }

        if (targetSectionId != null) {
          final targetIdx = survey.sections!.indexWhere(
            (s) => s.id == targetSectionId,
          );
          if (targetIdx != -1) {
            final jumpEntry = SurveyJumpEntryHelper.computeJumpEntryMap(
              survey: survey,
              jumpMap: currentJumpMap,
            );
            emit(
              SurveyNavigationUpdated(
                survey: survey,
                responseId: state.responseId,
                currentSectionIndex: targetIdx,
                visibilityMap: currentVisibility,
                requirementMap: currentRequirement,
                jumpMap: currentJumpMap,
                currentStep: state.currentStep,
                lockedSectionIndices: locked,
                jumpEntryQuestionBySectionId: jumpEntry,
              ),
            );
            return;
          }
        }
      }

      int nextIndex = state.currentSectionIndex + 1;
      bool foundNext = false;
      while (nextIndex < survey.sections!.length) {
        final nextSec = survey.sections![nextIndex];
        final bool isSectionVisible =
            currentVisibility["section_${nextSec.id}"] ?? true;

        if (isSectionVisible) {
          final jumpEntry = Map<int, int>.from(
            SurveyJumpEntryHelper.computeJumpEntryMap(
              survey: survey,
              jumpMap: currentJumpMap,
            ),
          )..remove(nextSec.id);
          emit(
            SurveyNavigationUpdated(
              survey: survey,
              responseId: state.responseId,
              currentSectionIndex: nextIndex,
              visibilityMap: currentVisibility,
              requirementMap: currentRequirement,
              jumpMap: currentJumpMap,
              currentStep: state.currentStep,
              lockedSectionIndices: locked,
              jumpEntryQuestionBySectionId: jumpEntry,
            ),
          );
          foundNext = true;
          break;
        }
        nextIndex++;
      }

      if (!foundNext) {
        emit(
          SurveyNavigationUpdated(
            survey: survey,
            responseId: state.responseId,
            currentSectionIndex: state.currentSectionIndex,
            visibilityMap: currentVisibility,
            requirementMap: currentRequirement,
            jumpMap: currentJumpMap,
            currentStep: state.currentStep,
            lockedSectionIndices: locked,
            jumpEntryQuestionBySectionId: state.jumpEntryQuestionBySectionId,
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
              jumpEntryQuestionBySectionId: state.jumpEntryQuestionBySectionId,
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

        final jumpEntry = Map<int, int>.from(state.jumpEntryQuestionBySectionId)
          ..remove(section.id);

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
            jumpEntryQuestionBySectionId: jumpEntry,
          ),
        );
      }
    }
  }
}
