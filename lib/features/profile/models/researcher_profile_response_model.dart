import '../../../core/enums/survey_enums.dart';
import '../../../core/models/survey/quota_coordinate.dart';

/// Researcher Profile Response Model
class ResearcherProfileResponseModel {
  final ResearcherUserModel user;
  final ResearcherInfoModel researcher;
  final SupervisorModel? supervisor;
  final List<ResearcherAssignmentModel> assignments;

  const ResearcherProfileResponseModel({
    required this.user,
    required this.researcher,
    this.supervisor,
    required this.assignments,
  });

  factory ResearcherProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ResearcherProfileResponseModel(
      user: ResearcherUserModel.fromJson(json['user'] as Map<String, dynamic>),
      researcher: ResearcherInfoModel.fromJson(
        json['researcher'] as Map<String, dynamic>,
      ),
      supervisor: json['supervisor'] != null
          ? SupervisorModel.fromJson(json['supervisor'] as Map<String, dynamic>)
          : null,
      assignments:
          (json['assignments'] as List?)
              ?.map(
                (e) => ResearcherAssignmentModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'researcher': researcher.toJson(),
      'supervisor': supervisor?.toJson(),
      'assignments': assignments.map((e) => e.toJson()).toList(),
    };
  }
}

/// Researcher User Model - Basic user information
class ResearcherUserModel {
  final int id;
  final String email;
  final String? mobile;
  final String name;

  const ResearcherUserModel({
    required this.id,
    required this.email,
    this.mobile,
    required this.name,
  });

  factory ResearcherUserModel.fromJson(Map<String, dynamic> json) {
    return ResearcherUserModel(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      mobile: json['mobile'] as String?,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'mobile': mobile, 'name': name};
  }
}

/// Researcher Info Model - Additional researcher information
class ResearcherInfoModel {
  final int id;
  final String? jobTitle;
  final String? employer;
  final String? specialization;

  const ResearcherInfoModel({
    required this.id,
    this.jobTitle,
    this.employer,
    this.specialization,
  });

  factory ResearcherInfoModel.fromJson(Map<String, dynamic> json) {
    return ResearcherInfoModel(
      id: json['id'] as int? ?? 0,
      jobTitle: json['job_title'] as String?,
      employer: json['employer'] as String?,
      specialization: json['specialization'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_title': jobTitle,
      'employer': employer,
      'specialization': specialization,
    };
  }
}

/// Supervisor Model - Supervisor information
class SupervisorModel {
  final int id;
  final String name;
  final String email;
  final String? mobile;

  const SupervisorModel({
    required this.id,
    required this.name,
    required this.email,
    this.mobile,
  });

  factory SupervisorModel.fromJson(Map<String, dynamic> json) {
    return SupervisorModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      mobile: json['mobile'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'mobile': mobile};
  }
}

/// Researcher Assignment Model - Assignment information
class ResearcherAssignmentModel {
  final int id;
  final int surveyId;
  final String surveyTitle;
  final AssignmentStatus status;
  final AssignmentType type;
  final List<ResearcherQuotaModel> quotas;

  const ResearcherAssignmentModel({
    required this.id,
    required this.surveyId,
    required this.surveyTitle,
    required this.status,
    required this.type,
    required this.quotas,
  });

  factory ResearcherAssignmentModel.fromJson(Map<String, dynamic> json) {
    return ResearcherAssignmentModel(
      id: json['id'] as int? ?? 0,
      surveyId: json['survey_id'] as int? ?? 0,
      surveyTitle: json['survey_title'] as String? ?? '',
      status: AssignmentStatus.fromJson(json['status'] as String?),
      type: AssignmentType.fromJson(json['type'] as String?),
      quotas:
          (json['quotas'] as List?)
              ?.map(
                (e) => ResearcherQuotaModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'survey_title': surveyTitle,
      'status': status.toJson(),
      'type': type.toJson(),
      'quotas': quotas.map((e) => e.toJson()).toList(),
    };
  }
}

/// Researcher Quota Model - one cell of a researcher's quota plan.
///
/// Identified by [quotaTargetId] (`null` if no target is yet resolved).
/// [coordinates] describe the bucket's `(criterion, category)` axes;
/// [displayLabel] is a server-built human-readable summary in Arabic.
class ResearcherQuotaModel {
  final int id;
  final int quotaId;
  final int assignmentId;
  final int? quotaTargetId;
  final int target;
  final int progress;
  final int collected;
  final int? serverRemaining;
  final int? responsesCount;
  final num progressPercent;
  final String displayLabel;
  final List<QuotaCoordinate> coordinates;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ResearcherQuotaModel({
    this.id = 0,
    this.quotaId = 0,
    this.assignmentId = 0,
    this.quotaTargetId,
    required this.target,
    this.progress = 0,
    this.collected = 0,
    this.serverRemaining,
    this.responsesCount,
    this.progressPercent = 0,
    this.displayLabel = '',
    this.coordinates = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ResearcherQuotaModel.fromJson(Map<String, dynamic> json) {
    int? parseOptionalInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.round();
      return int.tryParse(v.toString());
    }

    final coordsRaw = json['coordinates'];
    final coords = coordsRaw is List
        ? coordsRaw
            .whereType<Map<String, dynamic>>()
            .map(QuotaCoordinate.fromJson)
            .toList()
        : <QuotaCoordinate>[];

    return ResearcherQuotaModel(
      id: json['id'] as int? ?? 0,
      quotaId: json['quota_id'] as int? ?? json['id'] as int? ?? 0,
      assignmentId: json['assignment_id'] as int? ?? 0,
      quotaTargetId: parseOptionalInt(json['quota_target_id']),
      target: json['target'] as int? ?? json['limit'] as int? ?? 0,
      progress: json['progress'] as int? ?? json['used'] as int? ?? 0,
      collected: json['collected'] as int? ?? json['used'] as int? ?? 0,
      serverRemaining: parseOptionalInt(json['remaining']),
      responsesCount: parseOptionalInt(json['responses_count']),
      progressPercent: (json['progress_percent'] as num?) ?? 0,
      displayLabel: (json['display_label'] as String?) ?? '',
      coordinates: coords,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'quota_id': quotaId,
    'assignment_id': assignmentId,
    if (quotaTargetId != null) 'quota_target_id': quotaTargetId,
    'target': target,
    'progress': progress,
    'collected': collected,
    if (serverRemaining != null) 'remaining': serverRemaining,
    if (responsesCount != null) 'responses_count': responsesCount,
    'progress_percent': progressPercent,
    'display_label': displayLabel,
    'coordinates': coordinates.map((c) => c.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
