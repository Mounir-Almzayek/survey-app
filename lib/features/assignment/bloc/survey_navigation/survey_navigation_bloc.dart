import 'package:flutter_bloc/flutter_bloc.dart';
import 'survey_navigation_event.dart';
import 'survey_navigation_state.dart';

export 'survey_navigation_event.dart';
export 'survey_navigation_state.dart';

class SurveyNavigationBloc
    extends Bloc<SurveyNavigationEvent, SurveyNavigationState> {
  SurveyNavigationBloc() : super(SurveyNavigationInitial()) {
    on<SetSurvey>(_onSetSurvey);
    on<NextSection>(_onNextSection);
    on<PreviousSection>(_onPreviousSection);
    on<GoToSection>(_onGoToSection);
  }

  void _onSetSurvey(SetSurvey event, Emitter<SurveyNavigationState> emit) {
    emit(SurveyNavigationUpdated(
      survey: event.survey,
      currentSectionIndex: 0,
    ));
  }

  void _onNextSection(NextSection event, Emitter<SurveyNavigationState> emit) {
    final survey = state.survey;
    if (survey != null && survey.sections != null) {
      if (state.currentSectionIndex < survey.sections!.length - 1) {
        emit(SurveyNavigationUpdated(
          survey: survey,
          currentSectionIndex: state.currentSectionIndex + 1,
        ));
      }
    }
  }

  void _onPreviousSection(
    PreviousSection event,
    Emitter<SurveyNavigationState> emit,
  ) {
    final survey = state.survey;
    if (survey != null && state.currentSectionIndex > 0) {
      emit(SurveyNavigationUpdated(
        survey: survey,
        currentSectionIndex: state.currentSectionIndex - 1,
      ));
    }
  }

  void _onGoToSection(GoToSection event, Emitter<SurveyNavigationState> emit) {
    final survey = state.survey;
    if (survey != null && survey.sections != null) {
      if (event.index >= 0 && event.index < survey.sections!.length) {
        emit(SurveyNavigationUpdated(
          survey: survey,
          currentSectionIndex: event.index,
        ));
      }
    }
  }
}
