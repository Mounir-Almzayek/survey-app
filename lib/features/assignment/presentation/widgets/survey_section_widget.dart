import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/survey/survey_question_renderer.dart';
import '../../../../core/utils/survey_validator.dart';
import '../../bloc/survey_navigation/survey_navigation_bloc.dart';
import '../../bloc/save_section/save_section_bloc.dart';
import '../../models/save_section_models.dart';

class SurveySectionWidget extends StatefulWidget {
  const SurveySectionWidget({super.key});

  @override
  State<SurveySectionWidget> createState() => _SurveySectionWidgetState();
}

class _SurveySectionWidgetState extends State<SurveySectionWidget> {
  final Map<int, String?> _errors = {};

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<SurveyNavigationBloc, SurveyNavigationState>(
      listenWhen: (prev, curr) =>
          prev.currentSection?.id != curr.currentSection?.id,
      listener: (context, state) {
        if (state.currentSection != null) {
          context.read<SaveSectionBloc>().add(
            UpdateCurrentSection(state.currentSection!.id),
          );
        }
      },
      child: BlocBuilder<SurveyNavigationBloc, SurveyNavigationState>(
        builder: (context, navState) {
          final currentSection = navState.currentSection;
          if (currentSection == null) return const SizedBox.shrink();

          return BlocBuilder<SaveSectionBloc, SaveSectionState>(
            builder: (context, saveState) {
              final answers = saveState.saveRequest?.answers ?? [];
              final answersMap = {for (var a in answers) a.questionId: a.value};

              return Column(
                children: [
                  // Section Header
                  _buildHeader(
                    currentSection.title ?? "",
                    navState.progress,
                    navState.currentSectionIndex,
                    navState.survey?.sections?.length ?? 0,
                  ),

                  // Questions List
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.all(16.r),
                      itemCount: currentSection.questions?.length ?? 0,
                      separatorBuilder: (_, __) => SizedBox(height: 20.h),
                      itemBuilder: (context, index) {
                        final question = currentSection.questions![index];
                        final behavior = navState.getQuestionBehavior(
                          question.id,
                          defaultRequired: question.isRequired ?? false,
                        );

                        return SurveyQuestionRenderer(
                          question: question.copyWith(
                            isRequired: behavior.isRequired,
                          ),
                          value: answersMap[question.id],
                          isVisible: behavior.isVisible,
                          errorText: _errors[question.id],
                          onAnswerChange: (value) {
                            // Sanitize value: Empty strings should be null
                            final sanitizedValue =
                                SurveyValidator.sanitizeValue(value);

                            context.read<SaveSectionBloc>().add(
                              AddAnswer(
                                AnswerRequest(
                                  questionId: question.id,
                                  value: sanitizedValue,
                                ),
                              ),
                            );

                            // Trigger behavior refresh immediately on answer change
                            final updatedAnswersMap = Map<int, dynamic>.from(
                              answersMap,
                            );
                            updatedAnswersMap[question.id] = sanitizedValue;
                            context.read<SurveyNavigationBloc>().add(
                              RefreshBehavior(updatedAnswersMap),
                            );

                            setState(() {
                              _errors.remove(question.id);
                            });
                          },
                        );
                      },
                    ),
                  ),

                  // Navigation Buttons
                  _buildNavigation(context, navState, saveState, s),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    String title,
    double progress,
    int currentIndex,
    int totalCount,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        context.isPhoneLandscape ? 12.h : 45.h,
        20.w,
        context.isPhoneLandscape ? 12.h : 20.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Perfect Centered Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.w),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: context.adaptiveFont(17.sp),
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                    height: 1.3,
                  ),
                ),
              ),
              // Section Badge at the end
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient.withOpacity(0.1),
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${currentIndex + 1}/$totalCount',
                    style: TextStyle(
                      fontSize: context.adaptiveFont(12.sp),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.isPhoneLandscape ? 12.h : 24.h),
          // Animated Progress Bar
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: 10.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.border.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      height: 10.h,
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(5.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryStart.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(
    BuildContext context,
    SurveyNavigationState navState,
    SaveSectionState saveState,
    S s,
  ) {
    final isLast = navState.isLastSection;
    final isFirst = navState.isFirstSection;
    final isLoading = saveState is SaveSectionLoading;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20.r,
        context.isPhoneLandscape ? 12.r : 20.r,
        20.r,
        context.isPhoneLandscape ? 12.r : 35.r,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isFirst)
            IconButton.filledTonal(
              onPressed: isLoading ? null : () => _handlePrevious(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: context.adaptiveIcon(20.sp),
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.all(14.r),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          if (!isFirst) SizedBox(width: 16.w),
          Expanded(
            child: CustomElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => _handleNext(context, navState, isLast, s),
              isLoading: isLoading,
              title: isLast ? s.submit : s.next,
            ),
          ),
        ],
      ),
    );
  }

  void _handlePrevious(BuildContext context) {
    context.read<SurveyNavigationBloc>().add(PreviousSection());
  }

  void _handleNext(
    BuildContext context,
    SurveyNavigationState navState,
    bool isLast,
    S s,
  ) {
    if (_validateSection(navState, context)) {
      // Filter out answers for questions that are not visible or belong to hidden sections
      final answers =
          context.read<SaveSectionBloc>().state.saveRequest?.answers ?? [];
      final survey = navState.survey;

      final filteredAnswers = answers.where((answer) {
        // 1. Check if question itself is visible
        final qBehavior = navState.getQuestionBehavior(answer.questionId);
        if (!qBehavior.isVisible) return false;

        // 2. Check if the section containing this question is visible
        if (survey?.sections != null) {
          final section = survey!.sections!.firstWhere(
            (s) => s.questions?.any((q) => q.id == answer.questionId) ?? false,
            orElse: () =>
                navState.currentSection!, // Fallback to current section
          );
          if (!navState.isVisible("section_${section.id}")) return false;
        }

        return true;
      }).toList();

      // Update answers with filtered ones before submitting
      context.read<SaveSectionBloc>().add(
        SubmitSection(answers: filteredAnswers),
      );
    }
  }

  bool _validateSection(SurveyNavigationState navState, BuildContext context) {
    final section = navState.currentSection;
    if (section == null) return true;

    final answers =
        context.read<SaveSectionBloc>().state.saveRequest?.answers ?? [];
    final answersMap = {for (var a in answers) a.questionId: a.value};
    final locale = Localizations.localeOf(context).languageCode;

    final newErrors = <int, String?>{};
    bool hasError = false;

    for (var question in section.questions ?? []) {
      final behavior = navState.getQuestionBehavior(
        question.id,
        defaultRequired: question.isRequired ?? false,
      );
      if (!behavior.isVisible) continue;

      final val = answersMap[question.id];

      // 1. Required Check
      if (behavior.isRequired) {
        if (SurveyValidator.isValueEmpty(val)) {
          newErrors[question.id] = S.of(context).field_required;
          hasError = true;
          continue; // Move to next question if required check fails
        }
      }

      // 2. Custom Validations (Regex-based)
      final validationErrors = SurveyValidator.validateQuestion(
        question: question,
        value: val,
        locale: locale,
        isRequired: behavior.isRequired,
      );

      if (validationErrors.isNotEmpty) {
        newErrors[question.id] = validationErrors.join("\n");
        hasError = true;
      }
    }

    setState(() {
      _errors.clear();
      _errors.addAll(newErrors);
    });

    return !hasError;
  }
}
