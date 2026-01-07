import 'package:equatable/equatable.dart';

import 'question.dart';

/// Section model matching backend SectionWithRelations (simplified)
class Section extends Equatable {
  final int id;
  final int? surveyId;
  final String title;
  final String description;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<Question> questions;

  const Section({
    required this.id,
    required this.surveyId,
    required this.title,
    required this.description,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.questions = const [],
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    final questionsJson = json['questions'];
    return Section(
      id: json['id'] as int,
      surveyId: json['survey_id'] as int?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      questions: questionsJson is List
          ? questionsJson
              .map(
                (q) => Question.fromJson(q as Map<String, dynamic>),
              )
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'title': title,
      'description': description,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        surveyId,
        title,
        description,
        order,
        createdAt,
        updatedAt,
        deletedAt,
        questions,
      ];
}


