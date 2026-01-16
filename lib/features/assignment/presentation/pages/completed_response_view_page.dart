import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/survey/survey_question_renderer.dart';
import '../../../../core/models/survey/question_model.dart';
import '../../../responses/bloc/response_details/response_details_bloc.dart';
import '../../../responses/models/response_details.dart';
import '../../../assignment/repository/assignment_local_repository.dart';
import '../../../../core/models/survey/survey_model.dart';
import '../../../../core/models/survey/section_model.dart';

class CompletedResponseViewPage extends StatelessWidget {
  final int responseId;

  const CompletedResponseViewPage({
    super.key,
    required this.responseId,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider(
      create: (_) => ResponseDetailsBloc()
        ..add(LoadResponseDetails(responseId: responseId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.response_details_title),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<ResponseDetailsBloc, ResponseDetailsState>(
          builder: (context, state) {
            if (state is ResponseDetailsLoading) {
              return const Center(child: LoadingWidget());
            }

            if (state is ResponseDetailsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (state is ResponseDetailsLoaded) {
              return FutureBuilder<Survey?>(
                future: state.details.surveyId != null
                    ? AssignmentLocalRepository.getSurveyById(
                        state.details.surveyId!,
                      )
                    : Future.value(null),
                builder: (context, surveySnapshot) {
                  if (surveySnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: LoadingWidget());
                  }

                  final survey = surveySnapshot.data;
                  return _buildResponseView(context, state.details, survey);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildResponseView(
    BuildContext context,
    ResponseDetails details,
    Survey? survey,
  ) {
    // Create a map of questionId -> answer value
    final answersMap = {
      for (var answer in details.answers) answer.questionId: answer.value,
    };

    // Group answers by section if survey is available
    if (survey != null && survey.sections != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Survey Title
          if (details.surveyTitle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                details.surveyTitle!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
              ),
            ),
          // Sections with questions
          ..._buildSections(survey.sections!, answersMap),
        ],
      );
    } else {
      // Fallback: show answers in simple list if survey structure not available
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (details.surveyTitle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                details.surveyTitle!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
              ),
            ),
          ...details.answers.map((answer) => _buildSimpleAnswerCard(answer)),
        ],
      );
    }
  }

  List<Widget> _buildSections(
    List<Section> sections,
    Map<int, String> answersMap,
  ) {
    final widgets = <Widget>[];
    
    for (int i = 0; i < sections.length; i++) {
      final section = sections[i];
      
      // Section Header
      widgets.add(
        Container(
          margin: EdgeInsets.only(top: i > 0 ? 24 : 0, bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (section.title != null)
                Text(
                  section.title!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              if (section.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  section.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ],
          ),
        ),
      );

      // Questions in this section
      if (section.questions != null) {
        for (final question in section.questions!) {
          final answerValue = answersMap[question.id];
          if (answerValue != null) {
            widgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildQuestionWithAnswer(question, answerValue),
              ),
            );
          }
        }
      }

      // Divider between sections (except after last section)
      if (i < sections.length - 1) {
        widgets.add(
          const Divider(
            height: 32,
            thickness: 2,
            color: AppColors.border,
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildQuestionWithAnswer(Question question, String answerValue) {
    // Parse answer value based on question type
    dynamic parsedValue = answerValue;
    
    // Try to parse as number if question type is number
    if (question.type?.name == 'number') {
      parsedValue = num.tryParse(answerValue);
    }
    // Try to parse as list if question type is checkbox or multi-select
    else if (question.type?.name == 'checkbox' ||
        question.type?.name == 'multiSelectGrid') {
      try {
        parsedValue = answerValue.split(',').map((e) => e.trim()).toList();
      } catch (_) {
        parsedValue = [answerValue];
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Label
          if (question.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                question.label!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          // Answer using question renderer (read-only)
          SurveyQuestionRenderer(
            question: question,
            value: parsedValue,
            onAnswerChange: (_) {}, // No-op for read-only
            isVisible: true,
            isEditable: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleAnswerCard(ResponseAnswerDetail answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer.questionLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer.value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
