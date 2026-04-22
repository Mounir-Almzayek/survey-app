import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/models/survey/question_model.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/utils/survey_behavior_manager.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/survey/survey_question_renderer.dart';
import '../../bloc/answering/public_link_answering_bloc.dart';
import '../../bloc/answering/public_link_answering_event.dart';
import '../../bloc/answering/public_link_answering_state.dart';

/// Renders the current section of the public-link survey: a polished header
/// (section badge + title + activity bar), the list of visible questions,
/// and a bottom Continue/Submit button.
///
/// Conditional logic is applied via [SurveyBehaviorManager] on every build so
/// visibility/requirement reflect the latest answers.
class AnsweringSectionView extends StatelessWidget {
  final PublicLinkAnsweringSection state;
  final String surveyTitle;

  const AnsweringSectionView({
    super.key,
    required this.state,
    required this.surveyTitle,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    // Evaluate visibility/required against the merged set so cross-section
    // rules (e.g. "show Q5 in section 3 if Q1 in section 1 == 'yes'") fire
    // correctly — same contract the web frontend relies on.
    final behavior = SurveyBehaviorManager.calculateBehavior(
      logics: state.conditionalLogics,
      answers: state.mergedAnswers,
    );
    final visibilityMap =
        behavior['visibility'] as Map<String, bool>? ?? {};
    final requirementMap =
        behavior['requirement'] as Map<String, bool>? ?? {};

    bool isVisible(int id) => visibilityMap['question_$id'] ?? true;
    bool isRequired(int id, bool baseRequired) =>
        requirementMap['question_$id'] ?? baseRequired;

    final visibleQuestions = (state.section.questions ?? <Question>[])
        .where((q) => isVisible(q.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          surveyTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeader(context, state.section.title ?? '', state.sectionNumber,
              state.submitting),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(16.r),
              itemCount: visibleQuestions.length,
              separatorBuilder: (_, __) => SizedBox(height: 20.h),
              itemBuilder: (_, index) {
                final q = visibleQuestions[index];
                final required = isRequired(q.id, q.isRequired ?? false);
                return SurveyQuestionRenderer(
                  question: q.copyWith(isRequired: required),
                  value: state.answers[q.id],
                  isVisible: true,
                  isEditable: !state.submitting,
                  errorText: state.errors[q.id],
                  submitAttemptCount: state.submitAttemptCount,
                  onAnswerChange: (value) => context
                      .read<PublicLinkAnsweringBloc>()
                      .add(AnswerChanged(questionId: q.id, value: value)),
                );
              },
            ),
          ),
          _buildBottomBar(context, s),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String sectionTitle,
    int sectionNumber,
    bool submitting,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        context.isPhoneLandscape ? 12.h : 24.h,
        20.w,
        context.isPhoneLandscape ? 12.h : 16.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _SectionBadge(number: sectionNumber),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  sectionTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: context.adaptiveFont(16.sp),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Activity bar — animated indeterminate while submitting, static
          // muted track otherwise (we don't know total sections to compute %).
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: SizedBox(
              height: 4.h,
              child: submitting
                  ? const LinearProgressIndicator(
                      backgroundColor: AppColors.border,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    )
                  : Container(color: AppColors.border),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, S s) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        context.isPhoneLandscape ? 12.h : 16.h,
        20.w,
        context.isPhoneLandscape ? 12.h : 24.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: CustomElevatedButton(
          onPressed: state.submitting
              ? null
              : () => context
                  .read<PublicLinkAnsweringBloc>()
                  .add(const SubmitCurrentSection()),
          isLoading: state.submitting,
          title: s.continue_button,
        ),
      ),
    );
  }
}

class _SectionBadge extends StatelessWidget {
  final int number;

  const _SectionBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.w,
      height: 36.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryStart.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$number',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: context.adaptiveFont(14.sp),
        ),
      ),
    );
  }
}
