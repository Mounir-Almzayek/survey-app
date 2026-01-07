import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/response_details/response_details_bloc.dart';

class ResponseDetailsPage extends StatelessWidget {
  final int responseId;

  const ResponseDetailsPage({super.key, required this.responseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ResponseDetailsBloc()
            ..add(LoadResponseDetails(responseId: responseId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Response details')),
        body: SafeArea(
          child: BlocBuilder<ResponseDetailsBloc, ResponseDetailsState>(
            builder: (context, state) {
              if (state is ResponseDetailsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ResponseDetailsError) {
                return Center(child: Text(state.message));
              }

              if (state is ResponseDetailsLoaded) {
                final d = state.details;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      d.survey.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      d.survey.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    for (final answer in d.answers) ...[
                      Text(
                        'Q ${answer.questionId}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        answer.value,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
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
