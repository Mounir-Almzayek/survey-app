import 'package:equatable/equatable.dart';
import 'question_model.dart';

class Section extends Equatable {
  final int id;
  final int? surveyId;
  final String title;
  final String description;
  final int order;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  final List<Question>? questions;

  const Section({
    required this.id,
    this.surveyId,
    required this.title,
    required this.description,
    required this.order,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.questions,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      surveyId: json['survey_id'],
      title: json['title'],
      description: json['description'],
      order: json['order'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      questions: (json['questions'] as List?)
          ?.map((e) => Question.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'title': title,
      'description': description,
      'order': order,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'questions': questions?.map((e) => e.toJson()).toList(),
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
