import '../../../core/enums/survey_enums.dart';

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

/// Researcher Quota Model - Quota information for assignments
class ResearcherQuotaModel {
  final String gender;
  final String ageGroup;
  final int target;
  final int collected;
  final int progressPercent;

  const ResearcherQuotaModel({
    required this.gender,
    required this.ageGroup,
    required this.target,
    required this.collected,
    required this.progressPercent,
  });

  factory ResearcherQuotaModel.fromJson(Map<String, dynamic> json) {
    return ResearcherQuotaModel(
      gender: json['gender'] as String? ?? '',
      ageGroup: json['age_group'] as String? ?? '',
      target: json['target'] as int? ?? 0,
      collected: json['collected'] as int? ?? 0,
      progressPercent: json['progress_percent'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'age_group': ageGroup,
      'target': target,
      'collected': collected,
      'progress_percent': progressPercent,
    };
  }
}
