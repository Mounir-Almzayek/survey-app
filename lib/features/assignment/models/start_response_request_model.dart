import 'package:equatable/equatable.dart';
import '../../../../core/enums/survey_enums.dart';

/// Model for starting a survey response request
class StartResponseRequest extends Equatable {
  final int surveyId;
  final Gender gender;
  final AgeGroup ageGroup;
  final Map<String, double>? location;

  const StartResponseRequest({
    required this.surveyId,
    required this.gender,
    required this.ageGroup,
    this.location,
  });

  /// Create a copy with updated values
  StartResponseRequest copyWith({
    int? surveyId,
    Gender? gender,
    AgeGroup? ageGroup,
    Map<String, double>? location,
  }) {
    return StartResponseRequest(
      surveyId: surveyId ?? this.surveyId,
      gender: gender ?? this.gender,
      ageGroup: ageGroup ?? this.ageGroup,
      location: location ?? this.location,
    );
  }

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'gender': gender.toJson(),
      'age_group': ageGroup.toJson(),
      if (location != null) 'location': location,
    };
  }

  @override
  List<Object?> get props => [surveyId, gender, ageGroup, location];
}
