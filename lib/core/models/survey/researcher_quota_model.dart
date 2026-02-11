import 'package:equatable/equatable.dart';
import '../../enums/survey_enums.dart';
import 'assignment_model.dart';

/// ResearcherQuota Model - For quota tracking
class ResearcherQuota extends Equatable {
  final int id;
  final int assignmentId;
  final Gender gender;
  final AgeGroup ageGroup;
  final int target;
  final int progress;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final Assignment? assignment;

  const ResearcherQuota({
    required this.id,
    required this.assignmentId,
    required this.gender,
    required this.ageGroup,
    required this.target,
    this.progress = 0,
    required this.createdAt,
    required this.updatedAt,
    this.assignment,
  });

  factory ResearcherQuota.fromJson(Map<String, dynamic> json) {
    return ResearcherQuota(
      id: json['id'] as int? ?? 0,
      assignmentId: json['assignment_id'] as int? ?? 0,
      gender: Gender.fromJson(json['gender']),
      ageGroup: AgeGroup.fromJson(json['age_group']),
      target: json['target'] as int? ?? 0,
      progress: json['progress'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      assignment: json['assignment'] != null
          ? Assignment.fromJson(json['assignment'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'gender': gender.toJson(),
      'age_group': ageGroup.toJson(),
      'target': target,
      'progress': progress,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'assignment': assignment?.toJson(),
    };
  }

  /// Get remaining quota
  int get remaining => target - progress;

  /// Check if quota is completed
  bool get isCompleted => progress >= target;

  /// Get completion percentage
  double get completionPercentage => target > 0 ? (progress / target) * 100 : 0;

  /// Check if quota is nearly complete (>= 80%)
  bool get isNearlyComplete => completionPercentage >= 80;

  /// Get quota status description
  String get statusDescription {
    if (isCompleted) return 'Completed';
    if (isNearlyComplete) return 'Nearly Complete';
    if (progress > 0) return 'In Progress';
    return 'Not Started';
  }

  /// Get demographic description
  String get demographicDescription {
    String genderText = gender == Gender.male ? 'Male' : 'Female';
    String ageText = '';
    switch (ageGroup) {
      case AgeGroup.age18_29:
        ageText = '18-29';
        break;
      case AgeGroup.age30_39:
        ageText = '30-39';
        break;
      case AgeGroup.age40_49:
        ageText = '40-49';
        break;
      case AgeGroup.age50_59:
        ageText = '50-59';
        break;
      case AgeGroup.age60_69:
        ageText = '60-69';
        break;
      case AgeGroup.age70_79:
        ageText = '70-79';
        break;
      case AgeGroup.age80_89:
        ageText = '80-89';
        break;
      case AgeGroup.age90_99:
        ageText = '90-99';
        break;
      case AgeGroup.age100Plus:
        ageText = '100+';
        break;
    }
    return '$genderText ($ageText)';
  }

  @override
  List<Object?> get props => [
    id,
    assignmentId,
    gender,
    ageGroup,
    target,
    progress,
    createdAt,
    updatedAt,
    assignment,
  ];
}
