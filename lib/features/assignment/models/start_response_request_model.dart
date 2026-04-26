import 'package:equatable/equatable.dart';

/// Model for starting a survey response request.
///
/// As of the QuotaTarget migration the body carries only [location] and
/// [createdAt]; quota matching now happens at FINAL_SUBMIT on the server.
class StartResponseRequest extends Equatable {
  final int surveyId;
  final Map<String, double>? location;

  /// Wall-clock time captured when this request DTO was built. Sent as
  /// `created_at` so the server can record the moment of user action even
  /// when the request is replayed from the offline queue much later.
  final DateTime createdAt;

  StartResponseRequest({
    required this.surveyId,
    this.location,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  StartResponseRequest copyWith({
    int? surveyId,
    Map<String, double>? location,
    DateTime? createdAt,
  }) {
    return StartResponseRequest(
      surveyId: surveyId ?? this.surveyId,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    if (location != null) 'location': location,
    'created_at': createdAt.toUtc().toIso8601String(),
  };

  @override
  List<Object?> get props => [surveyId, location, createdAt];
}
