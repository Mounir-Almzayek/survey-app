import '../../../../core/models/survey/survey_model.dart';
import '../../../../core/models/survey/section_model.dart';

abstract class SurveyNavigationState {
  final Survey? survey;
  final int currentSectionIndex;

  SurveyNavigationState({
    this.survey,
    this.currentSectionIndex = 0,
  });

  Section? get currentSection {
    if (survey == null || survey!.sections == null) return null;
    if (currentSectionIndex < 0 || currentSectionIndex >= survey!.sections!.length) return null;
    return survey!.sections![currentSectionIndex];
  }

  bool get isFirstSection => currentSectionIndex == 0;
  bool get isLastSection {
    if (survey == null || survey!.sections == null) return true;
    return currentSectionIndex == survey!.sections!.length - 1;
  }

  double get progress {
    if (survey == null || survey!.sections == null || survey!.sections!.isEmpty) return 0;
    return (currentSectionIndex + 1) / survey!.sections!.length;
  }
}

class SurveyNavigationInitial extends SurveyNavigationState {
  SurveyNavigationInitial({super.survey, super.currentSectionIndex});
}

class SurveyNavigationUpdated extends SurveyNavigationState {
  SurveyNavigationUpdated({super.survey, super.currentSectionIndex});
}
