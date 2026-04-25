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
  final int? lastReachedSectionId;
  final List<AnswerRequest> answers;
  final double? latitude;
  final double? longitude;
  final bool isSynced;

  /// Wall-clock time captured when this request DTO was built. Sent as
  /// `created_at` so the server records the moment of user action even when
  /// the request is replayed from the offline queue much later.
  final DateTime createdAt;

  SaveSectionRequest({
    required this.sectionId,
    this.lastReachedSectionId,
    required this.answers,
    this.latitude,
    this.longitude,
    this.isSynced = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  SaveSectionRequest copyWith({
    int? sectionId,
    int? lastReachedSectionId,
    List<AnswerRequest>? answers,
    double? latitude,
    double? longitude,
    bool? isSynced,
    DateTime? createdAt,
  }) {
    return SaveSectionRequest(
      sectionId: sectionId ?? this.sectionId,
      lastReachedSectionId: lastReachedSectionId ?? this.lastReachedSectionId,
      answers: answers ?? this.answers,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'section_id': sectionId,
      'answers': answers.map((e) => e.toJson()).toList(),
      if (latitude != null && longitude != null)
        'location': {'latitude': latitude, 'longitude': longitude},
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  /// Convert to JSON including local-only fields (for local storage)
  Map<String, dynamic> toLocalJson() {
    return {
      ...toJson(),
      'last_reached_section_id': lastReachedSectionId,
      'is_synced': isSynced,
    };
  }

  factory SaveSectionRequest.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['created_at'];
    return SaveSectionRequest(
      sectionId: json['section_id'] as int? ?? 0,
      lastReachedSectionId: json['last_reached_section_id'] as int?,
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
      createdAt: rawCreatedAt is String ? DateTime.parse(rawCreatedAt) : null,
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
