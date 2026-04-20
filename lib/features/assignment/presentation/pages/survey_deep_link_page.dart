import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../features/public_links/models/public_link_answering_args.dart';
import '../../bloc/survey_by_short_code/survey_by_short_code_bloc.dart';
import '../../bloc/survey_by_short_code/survey_by_short_code_event.dart';
import '../../bloc/survey_by_short_code/survey_by_short_code_state.dart';

/// Deep-link entry point for survey public links.
///
/// Receives a [shortCode], fetches survey metadata via [SurveyByShortCodeBloc]
/// (unauthenticated GET /public-link/:short_code), and renders:
///
///  - Spinner while Idle | Loading.
///  - Survey preview (title + greeting) on Loaded. The "Start Survey" button
///    navigates to [PublicLinkAnsweringPage] which drives the server-side
///    section-by-section flow.
///  - Error view with Retry on Error. Offline errors auto-retry on reconnect
///    (handled inside [SurveyByShortCodeBloc]).
///
/// This page is a thin orchestration wrapper: it provides the bloc and
/// delegates rendering to the inline builder below.
class SurveyDeepLinkPage extends StatelessWidget {
  final String shortCode;

  const SurveyDeepLinkPage({super.key, required this.shortCode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SurveyByShortCodeBloc>(
      create: (_) => SurveyByShortCodeBloc()..add(FetchSurvey(shortCode)),
      child: _SurveyDeepLinkView(shortCode: shortCode),
    );
  }
}

class _SurveyDeepLinkView extends StatelessWidget {
  final String shortCode;

  const _SurveyDeepLinkView({required this.shortCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<SurveyByShortCodeBloc, SurveyByShortCodeState>(
        builder: (context, state) {
          if (state is SurveyByShortCodeLoaded) {
            return _LoadedBody(state: state, shortCode: shortCode);
          }
          if (state is SurveyByShortCodeError) {
            return _ErrorBody(kind: state.kind);
          }
          // Idle or Loading
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  final SurveyByShortCodeLoaded state;
  final String shortCode;

  const _LoadedBody({required this.state, required this.shortCode});

  @override
  Widget build(BuildContext context) {
    final link = state.result;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (link.surveyTitle.isNotEmpty) ...[
              Text(
                link.surveyTitle,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            if (link.greetingMessage.isNotEmpty) ...[
              Text(
                link.greetingMessage,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            if (link.surveyDescription.isNotEmpty) ...[
              Text(
                link.surveyDescription,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
            ] else ...[
              const SizedBox(height: 32),
            ],
            FilledButton(
              onPressed: () {
                context.push(
                  Routes.publicLinkAnsweringPath,
                  extra: PublicLinkAnsweringArgs(
                    shortCode: shortCode,
                    surveyTitle: link.surveyTitle,
                    requireLocation: link.requireLocation,
                  ),
                );
              },
              child: const Text('Start Survey'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final SurveyFetchErrorKind kind;

  const _ErrorBody({required this.kind});

  @override
  Widget build(BuildContext context) {
    final message = switch (kind) {
      SurveyFetchErrorKind.offline => 'No internet connection',
      SurveyFetchErrorKind.notFound => 'Survey not found',
      SurveyFetchErrorKind.serverError => 'Something went wrong',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context
                  .read<SurveyByShortCodeBloc>()
                  .add(const RetrySurveyFetch()),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
