import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../../../features/assignment/presentation/widgets/demographics_dialog.dart';
import '../../../features/assignment/state/survey_in_progress_notifier.dart';
import '../../../features/device_location/service/location_service.dart';
import '../bloc/answering/public_link_answering_bloc.dart';
import '../bloc/answering/public_link_answering_event.dart';
import '../bloc/answering/public_link_answering_state.dart';
import 'widgets/answering_completion_view.dart';
import 'widgets/answering_error_view.dart';
import 'widgets/answering_loading_view.dart';
import 'widgets/answering_section_view.dart';

/// Entry point for the public-link answering flow.
///
/// Owned by the deep-link path. Drives the demographics dialog, optional
/// location capture, and the section-by-section flow served by the backend.
class PublicLinkAnsweringPage extends StatelessWidget {
  final String shortCode;
  final String surveyTitle;
  final bool requireLocation;

  /// Survey-author goodbye copy surfaced on the completion screen. Empty when
  /// the survey didn't define one — UI falls back to a default thank-you.
  final String goodbyeMessage;

  const PublicLinkAnsweringPage({
    super.key,
    required this.shortCode,
    required this.surveyTitle,
    required this.requireLocation,
    this.goodbyeMessage = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PublicLinkAnsweringBloc>(
      create: (_) => PublicLinkAnsweringBloc(shortCode: shortCode),
      child: _PublicLinkAnsweringView(
        surveyTitle: surveyTitle,
        requireLocation: requireLocation,
        goodbyeMessage: goodbyeMessage,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// View – owns the demographics bootstrap and the in-progress flag for deep
// link gating, and delegates rendering to the right view per state.
// ---------------------------------------------------------------------------

class _PublicLinkAnsweringView extends StatefulWidget {
  final String surveyTitle;
  final bool requireLocation;
  final String goodbyeMessage;

  const _PublicLinkAnsweringView({
    required this.surveyTitle,
    required this.requireLocation,
    required this.goodbyeMessage,
  });

  @override
  State<_PublicLinkAnsweringView> createState() =>
      _PublicLinkAnsweringViewState();
}

class _PublicLinkAnsweringViewState extends State<_PublicLinkAnsweringView> {
  @override
  void initState() {
    super.initState();
    // Mark a survey as in progress so DeepLinkBloc can gate any incoming link
    // with a "discard current?" prompt instead of silently navigating away.
    SurveyInProgressNotifier.instance.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    SurveyInProgressNotifier.instance.value = false;
    super.dispose();
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
        UnifiedSnackbar.error(
          context,
          message: S.of(context).location_required_for_survey,
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
            AnsweringLoadingView(surveyTitle: widget.surveyTitle),
          PublicLinkAnsweringSection s => AnsweringSectionView(
              state: s,
              surveyTitle: widget.surveyTitle,
            ),
          PublicLinkAnsweringCompleted c => AnsweringCompletionView(
              rejectionReason: c.rejectionReason,
              goodbyeMessage: widget.goodbyeMessage,
            ),
          PublicLinkAnsweringError e => AnsweringErrorView(
              kind: e.kind,
              fallbackMessage: e.message,
              surveyTitle: widget.surveyTitle,
              onRetry: () => context
                  .read<PublicLinkAnsweringBloc>()
                  .add(const Retry()),
            ),
        };
      },
    );
  }
}
