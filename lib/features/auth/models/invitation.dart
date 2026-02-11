import 'package:equatable/equatable.dart';
import '../../../core/models/survey/survey_model.dart';

/// Invitation Model - For invitation system
class Invitation extends Equatable {
  final int id;
  final String token;
  final int userId;
  final int? surveyId;
  final int? supervisorId;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final Survey? survey;

  const Invitation({
    required this.id,
    required this.token,
    required this.userId,
    this.surveyId,
    this.supervisorId,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.survey,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] as int? ?? 0,
      token: json['token'] as String? ?? '',
      userId: json['user_id'] as int? ?? 0,
      surveyId: json['survey_id'],
      supervisorId: json['supervisor_id'],
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'].toString())
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      survey: json['survey'] != null ? Survey.fromJson(json['survey']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'user_id': userId,
      'survey_id': surveyId,
      'supervisor_id': supervisorId,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'survey': survey?.toJson(),
    };
  }

  /// Check if invitation is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if invitation is valid (not expired)
  bool get isValid => !isExpired;

  /// Get time until expiration
  Duration get timeUntilExpiration => expiresAt.difference(DateTime.now());

  /// Check if invitation expires within the next 24 hours
  bool get expiresSoon =>
      timeUntilExpiration.inHours < 24 &&
      timeUntilExpiration.inMilliseconds > 0;

  /// Check if this is a survey-specific invitation
  bool get isSurveyInvitation => surveyId != null && survey != null;

  @override
  List<Object?> get props => [
    id,
    token,
    userId,
    surveyId,
    supervisorId,
    expiresAt,
    createdAt,
    updatedAt,
    survey,
  ];
}
