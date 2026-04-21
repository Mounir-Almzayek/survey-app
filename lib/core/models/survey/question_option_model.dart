import 'package:equatable/equatable.dart';

import '../../utils/json_parser.dart';

class QuestionOption extends Equatable {
  final int id;
  final int? questionId;
  final String? label;
  final String? value;
  final int? order;
  final bool? isDefault;

  const QuestionOption({
    required this.id,
    this.questionId,
    this.label,
    this.value,
    this.order,
    this.isDefault,
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
    };
  }

  @override
  List<Object?> get props => [id, questionId, label, value, order, isDefault];
}
