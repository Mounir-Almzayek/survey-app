import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/survey_details/survey_details_bloc.dart';

class SurveyDetailsPage extends StatelessWidget {
  final int surveyId;

  const SurveyDetailsPage({
    super.key,
    required this.surveyId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SurveyDetailsBloc()
        ..add(LoadSurveyDetails(surveyId: surveyId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Survey details'),
        ),
        body: SafeArea(
          child: BlocBuilder<SurveyDetailsBloc, SurveyDetailsState>(
            builder: (context, state) {
              if (state is SurveyDetailsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is SurveyDetailsError) {
                return Center(child: Text(state.message));
              }

              if (state is SurveyDetailsLoaded) {
                final survey = state.survey;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      survey.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      survey.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    for (final section in survey.sections) ...[
                      Text(
                        section.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      if (section.description.isNotEmpty)
                        Text(
                          section.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      const SizedBox(height: 8),
                      for (final question in section.questions) ...[
                        Text(
                          question.label,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                      ],
                      const Divider(height: 24),
                    ],
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}


