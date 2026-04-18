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
  final Map<int, int> jumpMap; // Trigger ID -> Target Section ID
  final SurveyStep currentStep;

  /// Section indices in [survey.sections] that were left after a successful save + forward; answers are read-only when revisiting.
  final Set<int> lockedSectionIndices;

  /// Section id -> first question id shown when entering that section via a jump to a
  /// question; questions before it in section order are skipped (hidden / not required).
  final Map<int, int> jumpEntryQuestionBySectionId;

  SurveyNavigationState({
    this.survey,
    this.currentSectionIndex = 0,
    this.responseId,
    this.visibilityMap = const {},
    this.requirementMap = const {},
    this.jumpMap = const {},
    this.currentStep = SurveyStep.intro,
    this.lockedSectionIndices = const {},
    this.jumpEntryQuestionBySectionId = const {},
  });

  bool isSectionLocked(int sectionIndex) =>
      lockedSectionIndices.contains(sectionIndex);

  Section? get currentSection {
    if (survey == null || survey!.sections == null) return null;
    if (currentSectionIndex < 0 ||
        currentSectionIndex >= survey!.sections!.length) {
      return null;
    }
    return survey!.sections![currentSectionIndex];
  }

  /// Returns behavior for a specific question/section key
  QuestionBehavior getBehavior(String key, {bool defaultRequired = false}) {
    return QuestionBehavior(
      isVisible: visibilityMap[key] ?? true,
      isRequired: requirementMap[key] ?? defaultRequired,
    );
  }

  Section? _sectionContainingQuestion(int questionId) {
    if (survey?.sections == null) return null;
    for (final s in survey!.sections!) {
      if (s.questions?.any((q) => q.id == questionId) ?? false) return s;
    }
    return null;
  }

  /// True if [questionId] appears before the jump entry question in [sectionId]'s order.
  bool isSkippedBeforeJumpEntry(int sectionId, int questionId) {
    final entryQid = jumpEntryQuestionBySectionId[sectionId];
    if (entryQid == null) return false;
    Section? section;
    final sections = survey?.sections;
    if (sections != null) {
      for (final s in sections) {
        if (s.id == sectionId) {
          section = s;
          break;
        }
      }
    }
    if (section == null) return false;
    final questions = section.questions;
    if (questions == null) return false;
    final entryIdx = questions.indexWhere((q) => q.id == entryQid);
    final qIdx = questions.indexWhere((q) => q.id == questionId);
    if (entryIdx == -1 || qIdx == -1) return false;
    return qIdx < entryIdx;
  }

  /// Whether the current section was entered via a jump to a question inside the section.
  bool get enteredCurrentSectionViaIntraSectionJump {
    final section = currentSection;
    if (section == null) return false;
    return jumpEntryQuestionBySectionId.containsKey(section.id);
  }

  /// Helper for questions (respects conditional visibility, requirements, and intra-section jump skip).
  QuestionBehavior getQuestionBehavior(
    int questionId, {
    bool defaultRequired = false,
  }) {
    final owner = _sectionContainingQuestion(questionId);
    if (owner != null && isSkippedBeforeJumpEntry(owner.id, questionId)) {
      return const QuestionBehavior(isVisible: false, isRequired: false);
    }
    return getBehavior(
      "question_$questionId",
      defaultRequired: defaultRequired,
    );
  }

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
      if (!(visibilityMap[key] ?? true)) return false;
      if (isSkippedBeforeJumpEntry(section.id, q.id)) return false;
      return true;
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
    super.jumpMap,
    super.currentStep,
    super.lockedSectionIndices,
    super.jumpEntryQuestionBySectionId,
  });
}

class SurveyNavigationUpdated extends SurveyNavigationState {
  SurveyNavigationUpdated({
    super.survey,
    super.currentSectionIndex,
    super.responseId,
    super.visibilityMap,
    super.requirementMap,
    super.jumpMap,
    super.currentStep,
    super.lockedSectionIndices,
    super.jumpEntryQuestionBySectionId,
  });
}
