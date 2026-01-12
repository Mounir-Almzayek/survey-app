import 'location_data.dart';

/// Single answer item for a question
class AnswerInput {
  final int questionId;
  final dynamic value; // String, List<String>, bool, num, or null

  const AnswerInput({required this.questionId, required this.value});

  factory AnswerInput.fromJson(Map<String, dynamic> json) {
    return AnswerInput(
      questionId: json['question_id'] as int,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'question_id': questionId, 'value': value};
  }
}

/// Request model for saving section answers
/// POST /public-link/{short_code}/responses/{response_id}/sections/{section_id}
class SaveSectionAnswersRequest {
  final List<AnswerInput> answers;
  final LocationData? location;
  final bool isSynced;

  const SaveSectionAnswersRequest({
    required this.answers,
    this.location,
    this.isSynced = false,
  });

  factory SaveSectionAnswersRequest.fromJson(Map<String, dynamic> json) {
    return SaveSectionAnswersRequest(
      answers: (json['answers'] as List)
          .map((a) => AnswerInput.fromJson(a as Map<String, dynamic>))
          .toList(),
      location: json['location'] != null
          ? LocationData.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      isSynced: json['is_synced'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson({bool forApi = true}) {
    return {
      'answers': answers.map((a) => a.toJson()).toList(),
      if (location != null) 'location': location!.toJson(),
      if (!forApi) 'is_synced': isSynced,
    };
  }

  SaveSectionAnswersRequest copyWith({
    List<AnswerInput>? answers,
    LocationData? location,
    bool? isSynced,
  }) {
    return SaveSectionAnswersRequest(
      answers: answers ?? this.answers,
      location: location ?? this.location,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
