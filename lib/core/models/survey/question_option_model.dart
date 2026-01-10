import 'package:equatable/equatable.dart';

class QuestionOption extends Equatable {
  final int id;
  final int questionId;
  final String label;
  final String value;
  final int order;
  final bool isDefault;

  const QuestionOption({
    required this.id,
    required this.questionId,
    required this.label,
    required this.value,
    required this.order,
    this.isDefault = false,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'],
      questionId: json['question_id'],
      label: json['label'],
      value: json['value'],
      order: json['order'],
      isDefault: json['is_default'] ?? false,
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
