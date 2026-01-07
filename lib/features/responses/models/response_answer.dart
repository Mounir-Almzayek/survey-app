import 'package:equatable/equatable.dart';

/// Simplified answer item model matching AnswerItemSchema.
class ResponseAnswer extends Equatable {
  final int id;
  final int responseId;
  final int questionId;
  final String value;

  const ResponseAnswer({
    required this.id,
    required this.responseId,
    required this.questionId,
    required this.value,
  });

  factory ResponseAnswer.fromJson(Map<String, dynamic> json) {
    return ResponseAnswer(
      id: json['id'] as int,
      responseId: json['response_id'] as int,
      questionId: json['question_id'] as int,
      value: json['value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'response_id': responseId,
      'question_id': questionId,
      'value': value,
    };
  }

  @override
  List<Object?> get props => [id, responseId, questionId, value];
}


