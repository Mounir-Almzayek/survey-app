import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/survey/question_model.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/survey_behavior_manager.dart';
import '../../../core/widgets/survey/survey_question_renderer.dart';
import '../../../features/assignment/presentation/widgets/demographics_dialog.dart';
import '../../../features/device_location/service/location_service.dart';
import '../bloc/answering/public_link_answering_bloc.dart';
import '../bloc/answering/public_link_answering_event.dart';
import '../bloc/answering/public_link_answering_state.dart';

class PublicLinkAnsweringPage extends StatelessWidget {
  final String shortCode;
  final String surveyTitle;
  final bool requireLocation;

  const PublicLinkAnsweringPage({
    super.key,
    required this.shortCode,
    required this.surveyTitle,
    required this.requireLocation,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PublicLinkAnsweringBloc>(
      create: (_) => PublicLinkAnsweringBloc(shortCode: shortCode),
      child: _PublicLinkAnsweringView(
        surveyTitle: surveyTitle,
        requireLocation: requireLocation,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// View – owns the Demographics bootstrap and delegates to the right sub-widget
// ---------------------------------------------------------------------------

class _PublicLinkAnsweringView extends StatefulWidget {
  final String surveyTitle;
  final bool requireLocation;

  const _PublicLinkAnsweringView({
    required this.surveyTitle,
    required this.requireLocation,
  });

  @override
  State<_PublicLinkAnsweringView> createState() =>
      _PublicLinkAnsweringViewState();
}

class _PublicLinkAnsweringViewState extends State<_PublicLinkAnsweringView> {
  @override
  void initState() {
    super.initState();
    // Show demographics dialog on the next frame so the scaffold is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (!mounted) return;

    // 1. Collect demographics
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DemographicsDialog(),
    );

    if (!mounted) return;

    if (result == null) {
      // User dismissed without picking -> go back
      Navigator.of(context).pop();
      return;
    }

    final gender = result['gender'].toJson() as String;
    final ageGroup = result['ageGroup'].toJson() as String;

    // 2. Location (if required)
    ({double latitude, double longitude})? location;
    if (widget.requireLocation) {
      try {
        final loc = await LocationService.getCurrentLocation();
        location = (latitude: loc.latitude, longitude: loc.longitude);
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location is required for this survey'),
          ),
        );
        Navigator.of(context).pop();
        return;
      }
    }

    if (!mounted) return;

    // 3. Kick off the backend /start call
    context.read<PublicLinkAnsweringBloc>().add(
          StartAnswering(gender: gender, ageGroup: ageGroup, location: location),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublicLinkAnsweringBloc, PublicLinkAnsweringState>(
      builder: (context, state) {
        return switch (state) {
          PublicLinkAnsweringInitial() ||
          PublicLinkAnsweringCollectingDemographics() ||
          PublicLinkAnsweringStarting() =>
            _LoadingScaffold(title: widget.surveyTitle),
          PublicLinkAnsweringSection s => _SectionScaffold(
              state: s,
              surveyTitle: widget.surveyTitle,
            ),
          PublicLinkAnsweringCompleted c => _CompletedScaffold(state: c),
          PublicLinkAnsweringError e => _ErrorScaffold(
              state: e,
              surveyTitle: widget.surveyTitle,
            ),
        };
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Loading scaffold
// ---------------------------------------------------------------------------

class _LoadingScaffold extends StatelessWidget {
  final String title;

  const _LoadingScaffold({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

// ---------------------------------------------------------------------------
// Section scaffold
// ---------------------------------------------------------------------------

class _SectionScaffold extends StatelessWidget {
  final PublicLinkAnsweringSection state;
  final String surveyTitle;

  const _SectionScaffold({required this.state, required this.surveyTitle});

  @override
  Widget build(BuildContext context) {
    final behavior = SurveyBehaviorManager.calculateBehavior(
      logics: state.conditionalLogics,
      answers: state.answers,
    );
    final visibilityMap =
        behavior['visibility'] as Map<String, bool>? ?? {};

    bool isVisible(int id) => visibilityMap['question_$id'] ?? true;

    final visibleQuestions = (state.section.questions ?? <Question>[])
        .where((q) => isVisible(q.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(surveyTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: const LinearProgressIndicator(),
        ),
      ),
      body: Column(
        children: [
          // Section title
          if (state.section.title != null && state.section.title!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                state.section.title!,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          // Questions
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: visibleQuestions.length,
              itemBuilder: (context, index) {
                final q = visibleQuestions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SurveyQuestionRenderer(
                    question: q,
                    value: state.answers[q.id],
                    onAnswerChange: (val) => context
                        .read<PublicLinkAnsweringBloc>()
                        .add(AnswerChanged(questionId: q.id, value: val)),
                    errorText: state.errors[q.id],
                    isVisible: true,
                    isEditable: !state.submitting,
                  ),
                );
              },
            ),
          ),
          // Bottom bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: state.submitting
                    ? null
                    : () => context
                        .read<PublicLinkAnsweringBloc>()
                        .add(const SubmitCurrentSection()),
                child: state.submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Completed scaffold
// ---------------------------------------------------------------------------

class _CompletedScaffold extends StatelessWidget {
  final PublicLinkAnsweringCompleted state;

  const _CompletedScaffold({required this.state});

  @override
  Widget build(BuildContext context) {
    final hasRejection = state.rejectionReason != null &&
        state.rejectionReason!.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hasRejection ? 'Response Not Accepted' : 'Thank you',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (hasRejection)
                  Text(
                    state.rejectionReason!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  )
                else
                  Text(
                    'Your response has been submitted successfully.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => context.go(Routes.splashPath),
                  child: const Text('Back to home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error scaffold
// ---------------------------------------------------------------------------

class _ErrorScaffold extends StatelessWidget {
  final PublicLinkAnsweringError state;
  final String surveyTitle;

  const _ErrorScaffold({required this.state, required this.surveyTitle});

  @override
  Widget build(BuildContext context) {
    final message = switch (state.kind) {
      PublicLinkAnsweringErrorKind.offline => 'No internet connection',
      PublicLinkAnsweringErrorKind.server => 'Something went wrong',
      PublicLinkAnsweringErrorKind.unknown => state.message,
    };

    return Scaffold(
      appBar: AppBar(title: Text(surveyTitle)),
      body: Center(
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
                    .read<PublicLinkAnsweringBloc>()
                    .add(const Retry()),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
