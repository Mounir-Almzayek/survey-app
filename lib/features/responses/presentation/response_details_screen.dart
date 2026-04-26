import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/widgets/loading_widget.dart';
import '../bloc/response_details/response_details_bloc.dart';

class ResponseDetailsScreen extends StatelessWidget {
  const ResponseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(locale.response_details_title)),
      body: SafeArea(
        child: BlocBuilder<ResponseDetailsBloc, ResponseDetailsState>(
          builder: (context, state) {
            if (state is ResponseDetailsLoading) {
              return const Center(child: LoadingWidget());
            }

            if (state is ResponseDetailsError) {
              return Center(child: Text(state.message));
            }

            if (state is ResponseDetailsLoaded) {
              final d = state.details;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (d.surveyTitle != null)
                    Text(
                      d.surveyTitle!,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'الكوتا: ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          d.quotaTargetId == null
                              ? 'غير محدد'
                              : (d.displayLabel ?? 'غير محدد'),
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (final answer in d.answers) ...[
                    Text(
                      answer.questionLabel,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
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
    );
  }
}
