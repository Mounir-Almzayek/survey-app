import '../../../core/enums/survey_enums.dart';

/// Local metadata for a response: links responseId to demographic (who we're collecting for).
class ResponseMetadata {
  final int surveyId;
  final Gender gender;
  final AgeGroup ageGroup;

  const ResponseMetadata({
    required this.surveyId,
    required this.gender,
    required this.ageGroup,
  });

  Map<String, dynamic> toJson() => {
        'surveyId': surveyId,
        'gender': gender.toJson(),
        'ageGroup': ageGroup.toJson(),
      };

  factory ResponseMetadata.fromJson(Map<String, dynamic> json) {
    return ResponseMetadata(
      surveyId: json['surveyId'] as int,
      gender: Gender.fromJson(json['gender']),
      ageGroup: AgeGroup.fromJson(json['ageGroup']),
    );
  }
}
