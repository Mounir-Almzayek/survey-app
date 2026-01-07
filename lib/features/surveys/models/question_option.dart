import 'package:equatable/equatable.dart';

/// Question option model matching backend QuestionOption schema
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
    required this.isDefault,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] as int,
      questionId: json['question_id'] as int,
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      isDefault: json['is_default'] as bool? ?? false,
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
  List<Object?> get props => [
        id,
        questionId,
        label,
        value,
        order,
        isDefault,
      ];
}


