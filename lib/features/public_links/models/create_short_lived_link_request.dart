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

  CreateShortLivedLinkRequest copyWith({int? surveyId, Duration? duration}) {
    return CreateShortLivedLinkRequest(
      surveyId: surveyId ?? this.surveyId,
      duration: duration ?? this.duration,
    );
  }

  /// Builds the API body; [expires_at] is computed at call time as full ISO8601 UTC datetime (e.g. 2026-03-25T08:59:00.000Z).
  /// This avoids timezone ambiguity between client/device and server.
  Map<String, dynamic> toJson() {
    final d = DateTime.now().add(duration);
    return {'survey_id': surveyId, 'expires_at': d.toUtc().toIso8601String()};
  }
}
