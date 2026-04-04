/// Request model for creating a short-lived public link.
/// The API expects [survey_id] and [minutes] (integer); the server computes expiry.
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

  Map<String, dynamic> toJson() {
    return {
      'survey_id': surveyId,
      'minutes': durationMinutes,
    };
  }
}
