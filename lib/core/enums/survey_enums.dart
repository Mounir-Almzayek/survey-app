enum SurveyStatus {
  draft,
  published,
  archived;

  String toJson() => name.toUpperCase();

  static SurveyStatus fromJson(String value) {
    return SurveyStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
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

  static QuestionType fromJson(String value) {
    return QuestionType.values.firstWhere(
      (e) => e.toJson() == value.toUpperCase(),
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

  static ResponseStatus fromJson(String value) {
    return ResponseStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
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

  static ResponseLogEventType fromJson(String value) {
    return ResponseLogEventType.values.firstWhere(
      (e) => e.toJson() == value.toUpperCase(),
      orElse: () => ResponseLogEventType.start,
    );
  }
}

enum AnswerItemStatus {
  accepted,
  rejected;

  String toJson() => name.toUpperCase();

  static AnswerItemStatus fromJson(String value) {
    return AnswerItemStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
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

  static ConditionOperator fromJson(String value) {
    switch (value.toUpperCase()) {
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

  static ConditionJoinType fromJson(String value) {
    return ConditionJoinType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => ConditionJoinType.and,
    );
  }
}

enum ActionTargetType {
  question,
  section;

  String toJson() => name.toUpperCase();

  static ActionTargetType fromJson(String value) {
    return ActionTargetType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
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

  static ActionType fromJson(String value) {
    switch (value.toUpperCase()) {
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

  static ValidationType fromJson(String value) {
    return ValidationType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => ValidationType.questions,
    );
  }
}
