import 'package:equatable/equatable.dart';
import '../../../../core/enums/survey_enums.dart';

/// Model for starting a survey response request
class StartResponseRequest extends Equatable {
  final int surveyId;
  final Gender gender;
  final AgeGroup ageGroup;
  final Map<String, double>? location;

  /// Wall-clock time captured when this request DTO was built. Sent as
  /// `created_at` so the server can record the moment of user action even
  /// when the request is replayed from the offline queue much later.
  final DateTime createdAt;

  StartResponseRequest({
    required this.surveyId,
    required this.gender,
    required this.ageGroup,
    this.location,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  StartResponseRequest copyWith({
    int? surveyId,
    Gender? gender,
    AgeGroup? ageGroup,
    Map<String, double>? location,
    DateTime? createdAt,
  }) {
    return StartResponseRequest(
      surveyId: surveyId ?? this.surveyId,
      gender: gender ?? this.gender,
      ageGroup: ageGroup ?? this.ageGroup,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender.toJson(),
      'age_group': ageGroup.toJson(),
      if (location != null) 'location': location,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [surveyId, gender, ageGroup, location, createdAt];
}
