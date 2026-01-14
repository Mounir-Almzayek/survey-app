import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/survey/survey_question_renderer.dart';
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
                _buildHeader(currentSection.title ?? "", navState.progress),

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
                      );

                      return SurveyQuestionRenderer(
                        question: question,
                        value: answersMap[question.id],
                        isVisible: behavior.isVisible,
                        errorText: _errors[question.id],
                        onAnswerChange: (value) {
                          context.read<SaveSectionBloc>().add(
                                AddAnswer(
                                  AnswerRequest(
                                    questionId: question.id,
                                    value: value,
                                  ),
                                ),
                              );

                          // Trigger behavior refresh immediately on answer change
                          final updatedAnswersMap =
                              Map<int, dynamic>.from(answersMap);
                          updatedAnswersMap[question.id] = value;
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

  Widget _buildHeader(String title, double progress) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 50.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 6.h,
            ),
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
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (!isFirst)
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : () => _handlePrevious(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(s.previous),
              ),
            ),
          if (!isFirst) SizedBox(width: 16.w),
          Expanded(
            flex: 2,
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
      context.read<SaveSectionBloc>().add(SubmitSection());
    }
  }

  bool _validateSection(SurveyNavigationState navState, BuildContext context) {
    final section = navState.currentSection;
    if (section == null) return true;

    final answers =
        context.read<SaveSectionBloc>().state.saveRequest?.answers ?? [];
    final answersMap = {for (var a in answers) a.questionId: a.value};

    final newErrors = <int, String?>{};
    bool hasError = false;

    for (var question in section.questions ?? []) {
      final behavior = navState.getQuestionBehavior(question.id);
      if (behavior.isVisible && behavior.isRequired) {
        final val = answersMap[question.id];
        if (val == null ||
            (val is String && val.trim().isEmpty) ||
            (val is List && val.isEmpty)) {
          newErrors[question.id] = S.of(context).field_required;
          hasError = true;
        }
      }
    }

    setState(() {
      _errors.clear();
      _errors.addAll(newErrors);
    });

    return !hasError;
  }
}
