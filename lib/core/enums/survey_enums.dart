import 'package:flutter/widgets.dart';
import '../l10n/generated/l10n.dart';

enum SurveyStatus {
  draft,
  published,
  archived;

  String toJson() => name.toUpperCase();

  static SurveyStatus fromJson(dynamic value) {
    if (value == null) return SurveyStatus.draft;
    final String val = value.toString().toUpperCase();
    return SurveyStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == val,
      orElse: () => SurveyStatus.draft,
    );
  }
}

enum QuestionType {
  radio,
  checkbox,
  dropdown,
  textShort,
  textLong,
  number,
  date,
  time,
  datetime,
  file,
  rating,
  slider,
  gps,
  multiSelectGrid,
  singleSelectGrid;

  String toJson() => name.toUpperCase();

  static QuestionType fromJson(dynamic value) {
    if (value == null) return QuestionType.textShort;
    final String val = value.toString().toUpperCase();
    return QuestionType.values.firstWhere(
      (e) => e.toJson() == val,
      orElse: () => QuestionType.textShort,
    );
  }
}

// ResponseStatus enum for response tracking
enum ResponseStatus {
  draft, // DRAFT
  submitted, // SUBMITTED
  flagged, // FLAGGED
  rejected; // REJECTED

  String toJson() => name.toUpperCase();

  static ResponseStatus fromJson(dynamic value) {
    if (value == null) return ResponseStatus.draft;
    final String val = value.toString().toUpperCase();
    return ResponseStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == val,
      orElse: () => ResponseStatus.draft,
    );
  }
}

enum ResponseLogEventType {
  start,
  sectionSubmit,
  finalSubmit,
  statusChange,
  policyFlag,
  policyReject;

  String toJson() => name.toUpperCase();

  static ResponseLogEventType fromJson(dynamic value) {
    if (value == null) return ResponseLogEventType.start;
    final String val = value.toString().toUpperCase();
    return ResponseLogEventType.values.firstWhere(
      (e) => e.toJson() == val,
      orElse: () => ResponseLogEventType.start,
    );
  }
}

enum ConditionOperator {
  eq,
  neq,
  inList,
  notIn,
  gt,
  lt,
  gte,
  lte,
  contains,
  isEmpty,
  notEmpty;

  String toJson() {
    switch (this) {
      case ConditionOperator.eq:
        return 'EQ';
      case ConditionOperator.neq:
        return 'NEQ';
      case ConditionOperator.inList:
        return 'IN';
      case ConditionOperator.notIn:
        return 'NOTIN';
      case ConditionOperator.gt:
        return 'GT';
      case ConditionOperator.lt:
        return 'LT';
      case ConditionOperator.gte:
        return 'GTE';
      case ConditionOperator.lte:
        return 'LTE';
      case ConditionOperator.contains:
        return 'CONTAINS';
      case ConditionOperator.isEmpty:
        return 'IS_EMPTY';
      case ConditionOperator.notEmpty:
        return 'NOT_EMPTY';
    }
  }

  static ConditionOperator fromJson(dynamic value) {
    if (value == null) return ConditionOperator.eq;
    final String val = value.toString().toUpperCase();
    switch (val) {
      case 'EQ':
        return ConditionOperator.eq;
      case 'NEQ':
        return ConditionOperator.neq;
      case 'IN':
        return ConditionOperator.inList;
      case 'NOTIN':
        return ConditionOperator.notIn;
      case 'GT':
        return ConditionOperator.gt;
      case 'LT':
        return ConditionOperator.lt;
      case 'GTE':
        return ConditionOperator.gte;
      case 'LTE':
        return ConditionOperator.lte;
      case 'CONTAINS':
        return ConditionOperator.contains;
      case 'IS_EMPTY':
        return ConditionOperator.isEmpty;
      case 'NOT_EMPTY':
        return ConditionOperator.notEmpty;
      default:
        return ConditionOperator.eq;
    }
  }
}

enum ConditionJoinType {
  and,
  or;

  String toJson() => name.toUpperCase();

  static ConditionJoinType fromJson(dynamic value) {
    if (value == null) return ConditionJoinType.and;
    final String val = value.toString().toUpperCase();
    return ConditionJoinType.values.firstWhere(
      (e) => e.name.toUpperCase() == val,
      orElse: () => ConditionJoinType.and,
    );
  }
}

enum ActionTargetType {
  question,
  section;

  String toJson() => name.toUpperCase();

  static ActionTargetType fromJson(dynamic value) {
    if (value == null) return ActionTargetType.question;
    final String val = value.toString().toUpperCase();
    return ActionTargetType.values.firstWhere(
      (e) => e.name.toUpperCase() == val,
      orElse: () => ActionTargetType.question,
    );
  }
}

enum ActionType {
  show,
  hide,
  jump,
  setRequired,
  unsetRequired;

  String toJson() {
    switch (this) {
      case ActionType.show:
        return 'SHOW';
      case ActionType.hide:
        return 'HIDE';
      case ActionType.jump:
        return 'JUMP';
      case ActionType.setRequired:
        return 'SET_REQUIRED';
      case ActionType.unsetRequired:
        return 'UNSET_REQUIRED';
    }
  }

  static ActionType fromJson(dynamic value) {
    if (value == null) return ActionType.show;
    final String val = value.toString().toUpperCase();
    switch (val) {
      case 'SHOW':
        return ActionType.show;
      case 'HIDE':
        return ActionType.hide;
      case 'JUMP':
        return ActionType.jump;
      case 'SET_REQUIRED':
        return ActionType.setRequired;
      case 'UNSET_REQUIRED':
        return ActionType.unsetRequired;
      default:
        return ActionType.show;
    }
  }
}

enum ValidationType {
  questions;

  String toJson() => name.toUpperCase();

  static ValidationType fromJson(dynamic value) {
    if (value == null) return ValidationType.questions;
    final String val = value.toString().toUpperCase();
    return ValidationType.values.firstWhere(
      (e) => e.name.toUpperCase() == val,
      orElse: () => ValidationType.questions,
    );
  }
}

enum AssignmentStatus {
  pending,
  inProgress,
  completed,
  revoked;

  String toJson() {
    switch (this) {
      case AssignmentStatus.pending:
        return 'PENDING';
      case AssignmentStatus.inProgress:
        return 'IN_PROGRESS';
      case AssignmentStatus.completed:
        return 'COMPLETED';
      case AssignmentStatus.revoked:
        return 'REVOKED';
    }
  }

  static AssignmentStatus fromJson(dynamic value) {
    if (value == null) return AssignmentStatus.pending;
    final String val = value.toString().toUpperCase();
    switch (val) {
      case 'PENDING':
        return AssignmentStatus.pending;
      case 'IN_PROGRESS':
        return AssignmentStatus.inProgress;
      case 'COMPLETED':
        return AssignmentStatus.completed;
      case 'REVOKED':
        return AssignmentStatus.revoked;
      default:
        return AssignmentStatus.pending;
    }
  }
}

/// PhysicalDeviceStatus enum for device management
enum PhysicalDeviceStatus {
  pending,
  active,
  inactive,
  lost;

  String toJson() => name.toUpperCase();

  static PhysicalDeviceStatus fromJson(dynamic value) {
    if (value == null) return PhysicalDeviceStatus.pending;
    final String val = value.toString().toUpperCase();
    return PhysicalDeviceStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == val,
      orElse: () => PhysicalDeviceStatus.pending,
    );
  }
}

/// PhysicalDeviceLogEventType enum for device log entries
enum PhysicalDeviceLogEventType {
  location,
  status,
  other;

  String toJson() => name.toUpperCase();

  static PhysicalDeviceLogEventType fromJson(dynamic value) {
    if (value == null) return PhysicalDeviceLogEventType.other;
    final String val = value.toString().toUpperCase();
    return PhysicalDeviceLogEventType.values.firstWhere(
      (e) => e.name.toUpperCase() == val,
      orElse: () => PhysicalDeviceLogEventType.other,
    );
  }
}

/// ZoneAdministrativeClass enum for geographic zones
enum ZoneAdministrativeClass {
  region,
  governorate,
  city,
  administrativeCenter;

  String toJson() => name.toUpperCase();

  static ZoneAdministrativeClass fromJson(dynamic value) {
    if (value == null) return ZoneAdministrativeClass.region;
    final String val = value.toString().toUpperCase();
    return ZoneAdministrativeClass.values.firstWhere(
      (e) => e.name.toUpperCase() == val,
      orElse: () => ZoneAdministrativeClass.region,
    );
  }
}

/// Gender enum for quota tracking
enum Gender {
  male,
  female;

  String toJson() => name.toUpperCase();

  static Gender fromJson(dynamic value) {
    if (value == null) return Gender.male;
    final String val = value.toString().toUpperCase();
    return Gender.values.firstWhere(
      (e) => e.name.toUpperCase() == val,
      orElse: () => Gender.male,
    );
  }
}

/// AgeGroup enum for quota tracking
enum AgeGroup {
  age18_29,
  age30_39,
  age40_49,
  age50_59,
  age60_69,
  age70_79,
  age80_89,
  age90_99,
  age100Plus;

  String toJson() {
    switch (this) {
      case AgeGroup.age18_29:
        return "AGE_18_29";
      case AgeGroup.age30_39:
        return "AGE_30_39";
      case AgeGroup.age40_49:
        return "AGE_40_49";
      case AgeGroup.age50_59:
        return "AGE_50_59";
      case AgeGroup.age60_69:
        return "AGE_60_69";
      case AgeGroup.age70_79:
        return "AGE_70_79";
      case AgeGroup.age80_89:
        return "AGE_80_89";
      case AgeGroup.age90_99:
        return "AGE_90_99";
      case AgeGroup.age100Plus:
        return "AGE_100_PLUS";
    }
  }

  static AgeGroup fromJson(dynamic value) {
    if (value == null) return AgeGroup.age18_29;
    final String val = value.toString().toUpperCase();
    switch (val) {
      case "AGE_18_29":
      case "18-29":
        return AgeGroup.age18_29;
      case "AGE_30_39":
      case "30-39":
        return AgeGroup.age30_39;
      case "AGE_40_49":
      case "40-49":
        return AgeGroup.age40_49;
      case "AGE_50_59":
      case "50-59":
        return AgeGroup.age50_59;
      case "AGE_60_69":
      case "60-69":
        return AgeGroup.age60_69;
      case "AGE_70_79":
      case "70-79":
        return AgeGroup.age70_79;
      case "AGE_80_89":
      case "80-89":
        return AgeGroup.age80_89;
      case "AGE_90_99":
      case "90-99":
        return AgeGroup.age90_99;
      case "AGE_100_PLUS":
      case "100+":
        return AgeGroup.age100Plus;
      default:
        return AgeGroup.age18_29;
    }
  }

  String localized(dynamic contextOrS) {
    final s = contextOrS is S ? contextOrS : S.of(contextOrS as BuildContext);
    switch (this) {
      case AgeGroup.age18_29:
        return s.age_18_29;
      case AgeGroup.age30_39:
        return s.age_30_39;
      case AgeGroup.age40_49:
        return s.age_40_49;
      case AgeGroup.age50_59:
        return s.age_50_59;
      case AgeGroup.age60_69:
        return s.age_60_69;
      case AgeGroup.age70_79:
        return s.age_70_79;
      case AgeGroup.age80_89:
        return s.age_80_89;
      case AgeGroup.age90_99:
        return s.age_90_99;
      case AgeGroup.age100Plus:
        return s.age_100_plus;
    }
  }
}

extension GenderX on Gender {
  String localized(dynamic contextOrS) {
    final s = contextOrS is S ? contextOrS : S.of(contextOrS as BuildContext);
    switch (this) {
      case Gender.male:
        return s.gender_male;
      case Gender.female:
        return s.gender_female;
    }
  }
}

/// ReportSchedule enum for report scheduling
enum ReportSchedule {
  hourly,
  daily,
  weekly,
  monthly,
  quarterly,
  yearly;

  String toJson() => name.toUpperCase();

  static ReportSchedule fromJson(dynamic value) {
    if (value == null) return ReportSchedule.daily;
    final String val = value.toString().toUpperCase();
    return ReportSchedule.values.firstWhere(
      (e) => e.name.toUpperCase() == val,
      orElse: () => ReportSchedule.daily,
    );
  }
}

/// ReportFormat enum for report export formats
enum ReportFormat {
  csv,
  excel,
  pdf;

  String toJson() => name.toUpperCase();

  static ReportFormat fromJson(dynamic value) {
    if (value == null) return ReportFormat.csv;
    final String val = value.toString().toUpperCase();
    return ReportFormat.values.firstWhere(
      (e) => e.name.toUpperCase() == val,
      orElse: () => ReportFormat.csv,
    );
  }
}

/// AggregationType enum for report metric aggregation
enum AggregationType {
  count,
  sum,
  avg;

  String toJson() => name.toUpperCase();

  static AggregationType fromJson(dynamic value) {
    if (value == null) return AggregationType.count;
    final String val = value.toString().toUpperCase();
    return AggregationType.values.firstWhere(
      (e) => e.name.toUpperCase() == val,
      orElse: () => AggregationType.count,
    );
  }
}

/// MetricsFiltersTypes enum for report metric filters
enum MetricsFiltersTypes {
  range,
  eq,
  notEq,
  lt,
  gt,
  lte,
  gte;

  String toJson() => name.toUpperCase();

  static MetricsFiltersTypes fromJson(dynamic value) {
    if (value == null) return MetricsFiltersTypes.range;
    final String val = value.toString().toUpperCase();
    return MetricsFiltersTypes.values.firstWhere(
      (e) => e.name.toUpperCase() == val,
      orElse: () => MetricsFiltersTypes.range,
    );
  }
}

/// AssignmentType enum for assignment types
enum AssignmentType {
  bounded,
  unbounded;

  String toJson() => name.toUpperCase();

  static AssignmentType fromJson(dynamic value) {
    if (value == null) return AssignmentType.unbounded;
    final String val = value.toString().toUpperCase();
    switch (val) {
      case 'BOUNDED':
        return AssignmentType.bounded;
      case 'UNBOUNDED':
        return AssignmentType.unbounded;
      default:
        return AssignmentType.unbounded;
    }
  }
}
