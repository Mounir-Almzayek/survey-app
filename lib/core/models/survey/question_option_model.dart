import 'package:equatable/equatable.dart';

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
      id: json['id'],
      questionId: json['question_id'],
      label: json['label'],
      value: json['value'],
      order: json['order'],
      isDefault: json['is_default'],
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
