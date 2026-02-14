/// Request model for creating a short-lived public link.
/// [expires_at] is derived at call time in [toJson] from [duration].
class CreateShortLivedLinkRequest {
  final int surveyId;
  final Duration duration;

  const CreateShortLivedLinkRequest({
    this.surveyId = 0,
    this.duration = const Duration(minutes: 1),
  });

  int get durationMinutes => duration.inMinutes;

  CreateShortLivedLinkRequest copyWith({
    int? surveyId,
    Duration? duration,
  }) {
    return CreateShortLivedLinkRequest(
      surveyId: surveyId ?? this.surveyId,
      duration: duration ?? this.duration,
    );
  }

  /// Builds the API body; [expires_at] is computed at call time.
  Map<String, dynamic> toJson() {
    return {
      'survey_id': surveyId,
      'expires_at': DateTime.now().add(duration).toIso8601String(),
    };
  }
}
