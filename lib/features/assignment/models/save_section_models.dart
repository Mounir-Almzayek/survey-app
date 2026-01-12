class AnswerRequest {
  final int questionId;
  final dynamic value;

  AnswerRequest({required this.questionId, required this.value});

  Map<String, dynamic> toJson() {
    return {'question_id': questionId, 'value': value};
  }
}

class SaveSectionRequest {
  final int sectionId;
  final List<AnswerRequest> answers;
  final double? latitude;
  final double? longitude;
  final bool isSynced;

  SaveSectionRequest({
    required this.sectionId,
    required this.answers,
    this.latitude,
    this.longitude,
    this.isSynced = false,
  });

  SaveSectionRequest copyWith({
    int? sectionId,
    List<AnswerRequest>? answers,
    double? latitude,
    double? longitude,
    bool? isSynced,
  }) {
    return SaveSectionRequest(
      sectionId: sectionId ?? this.sectionId,
      answers: answers ?? this.answers,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'section_id': sectionId,
      'answers': answers.map((e) => e.toJson()).toList(),
      'is_synced': isSynced,
      if (latitude != null && longitude != null)
        'location': {'latitude': latitude, 'longitude': longitude},
    };
  }

  factory SaveSectionRequest.fromJson(Map<String, dynamic> json) {
    return SaveSectionRequest(
      sectionId: json['section_id'] as int? ?? 0,
      isSynced: json['is_synced'] as bool? ?? false,
      answers:
          (json['answers'] as List?)
              ?.map(
                (e) => AnswerRequest(
                  questionId: e['question_id'] as int,
                  value: e['value'],
                ),
              )
              .toList() ??
          [],
      latitude: json['location']?['latitude'] as double?,
      longitude: json['location']?['longitude'] as double?,
    );
  }
}

class SaveSectionResponse {
  final bool success;
  final String message;
  final bool isComplete;
  final bool isQueued;

  SaveSectionResponse({
    required this.success,
    required this.message,
    required this.isComplete,
    this.isQueued = false,
  });

  factory SaveSectionResponse.fromJson(Map<String, dynamic> json) {
    return SaveSectionResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      isComplete: json['data']?['is_complete'] as bool? ?? false,
      isQueued: false,
    );
  }
}
