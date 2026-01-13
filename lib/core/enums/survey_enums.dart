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

enum ResponseStatus {
  draft,
  submitted,
  flagged,
  rejected;

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

enum AnswerItemStatus {
  accepted,
  rejected;

  String toJson() => name.toUpperCase();

  static AnswerItemStatus fromJson(dynamic value) {
    if (value == null) return AnswerItemStatus.accepted;
    final String val = value.toString().toUpperCase();
    return AnswerItemStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == val,
      orElse: () => AnswerItemStatus.accepted,
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
  completed;

  String toJson() {
    switch (this) {
      case AssignmentStatus.pending:
        return 'PENDING';
      case AssignmentStatus.inProgress:
        return 'IN_PROGRESS';
      case AssignmentStatus.completed:
        return 'COMPLETED';
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
      default:
        return AssignmentStatus.pending;
    }
  }
}
