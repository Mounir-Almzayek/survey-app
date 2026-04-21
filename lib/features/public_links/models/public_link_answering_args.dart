import 'package:equatable/equatable.dart';

/// Navigation arguments for `PublicLinkAnsweringPage`.
///
/// Carried through go_router's `extra`. Captured upfront from the resolve
/// (`GET /public-link/:short_code`) response so the answering page can render
/// its scaffold without a second fetch — and so the completion screen can
/// surface the survey-author's goodbye message.
class PublicLinkAnsweringArgs extends Equatable {
  final String shortCode;
  final String surveyTitle;
  final bool requireLocation;

  /// Author-provided closing copy for the completion screen. Empty when the
  /// survey didn't define one — the UI then falls back to the default
  /// localized "Thank you" line.
  final String goodbyeMessage;

  const PublicLinkAnsweringArgs({
    required this.shortCode,
    required this.surveyTitle,
    required this.requireLocation,
    this.goodbyeMessage = '',
  });

  @override
  List<Object?> get props =>
      [shortCode, surveyTitle, requireLocation, goodbyeMessage];
}
