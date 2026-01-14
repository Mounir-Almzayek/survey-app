import '../../../../core/models/survey/survey_model.dart';
import '../../../../core/models/survey/section_model.dart';
import '../../../../core/models/survey/question_model.dart';

class QuestionBehavior {
  final bool isVisible;
  final bool isRequired;

  const QuestionBehavior({this.isVisible = true, this.isRequired = false});
}

enum SurveyStep { intro, survey, completion }

abstract class SurveyNavigationState {
  final Survey? survey;
  final int currentSectionIndex;
  final int? responseId;
  final Map<String, bool> visibilityMap; // "question_5" or "section_2" -> bool
  final Map<String, bool> requirementMap; // "question_5" or "section_2" -> bool
  final SurveyStep currentStep;

  SurveyNavigationState({
    this.survey,
    this.currentSectionIndex = 0,
    this.responseId,
    this.visibilityMap = const {},
    this.requirementMap = const {},
    this.currentStep = SurveyStep.intro,
  });

  Section? get currentSection {
    if (survey == null || survey!.sections == null) return null;
    if (currentSectionIndex < 0 ||
        currentSectionIndex >= survey!.sections!.length)
      return null;
    return survey!.sections![currentSectionIndex];
  }

  /// Returns behavior for a specific question/section key
  QuestionBehavior getBehavior(String key) {
    return QuestionBehavior(
      isVisible: visibilityMap[key] ?? true,
      isRequired: requirementMap[key] ?? false,
    );
  }

  /// Helper for questions
  QuestionBehavior getQuestionBehavior(int questionId) =>
      getBehavior("question_$questionId");

  /// Helper for sections
  QuestionBehavior getSectionBehavior(int sectionId) =>
      getBehavior("section_$sectionId");

  /// Returns list of visible sections in the survey
  List<Section> get visibleSections {
    if (survey == null || survey!.sections == null) return [];
    return survey!.sections!
        .where((s) => isVisible("section_${s.id}"))
        .toList();
  }

  /// Returns list of visible questions in the current section
  List<Question> get visibleQuestions {
    final section = currentSection;
    if (section == null || section.questions == null) return [];

    return section.questions!.where((q) {
      final key = "question_${q.id}";
      return isVisible(key);
    }).toList();
  }

  bool isVisible(String key) => visibilityMap[key] ?? true;
  bool isRequired(String key) => requirementMap[key] ?? false;

  bool get isFirstSection {
    final sections = visibleSections;
    if (sections.isEmpty) return true;
    return currentSection?.id == sections.first.id;
  }

  bool get isLastSection {
    final sections = visibleSections;
    if (sections.isEmpty) return true;
    return currentSection?.id == sections.last.id;
  }

  double get progress {
    final sections = visibleSections;
    if (sections.isEmpty) return 0;
    final currentIndex = sections.indexWhere((s) => s.id == currentSection?.id);
    if (currentIndex == -1) return 0;
    return (currentIndex + 1) / sections.length;
  }
}

class SurveyNavigationInitial extends SurveyNavigationState {
  SurveyNavigationInitial({
    super.survey,
    super.currentSectionIndex,
    super.responseId,
    super.visibilityMap,
    super.requirementMap,
    super.currentStep,
  });
}

class SurveyNavigationUpdated extends SurveyNavigationState {
  SurveyNavigationUpdated({
    super.survey,
    super.currentSectionIndex,
    super.responseId,
    super.visibilityMap,
    super.requirementMap,
    super.currentStep,
  });
}
