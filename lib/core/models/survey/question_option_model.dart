import 'package:equatable/equatable.dart';

import '../../utils/json_parser.dart';

class QuestionOption extends Equatable {
  final int id;
  final int? questionId;
  final String? label;
  final String? value;
  final int? order;
  final bool? isDefault;

  /// Marks this option as the "Other" slot — when selected, the UI prompts
  /// for free-text input and the answer value carries that text instead of
  /// the option's literal `value`. Defaults to false; matches the web's
  /// `is_other` column on `question_option`.
  final bool isOther;

  const QuestionOption({
    required this.id,
    this.questionId,
    this.label,
    this.value,
    this.order,
    this.isDefault,
    this.isOther = false,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: JsonParser.asInt(json['id']),
      questionId: JsonParser.asIntOrNull(json['question_id']),
      label: JsonParser.asStringOrNull(json['label']),
      value: JsonParser.asStringOrNull(json['value']),
      order: JsonParser.asIntOrNull(json['order']),
      isDefault: json['is_default'] is bool
          ? json['is_default'] as bool
          : null,
      isOther: json['is_other'] is bool ? json['is_other'] as bool : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'label': label,
      'value': value,
      'order': order,
      'is_default': isDefault,
      'is_other': isOther,
    };
  }

  @override
  List<Object?> get props =>
      [id, questionId, label, value, order, isDefault, isOther];
}
