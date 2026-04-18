/// Request model for creating a public link. Only [survey_id] is sent; server sets policy.
class CreateShortLivedLinkRequest {
  final int surveyId;

  const CreateShortLivedLinkRequest({this.surveyId = 0});

  CreateShortLivedLinkRequest copyWith({int? surveyId}) {
    return CreateShortLivedLinkRequest(
      surveyId: surveyId ?? this.surveyId,
    );
  }

  Map<String, dynamic> toJson() => {'survey_id': surveyId};
}
