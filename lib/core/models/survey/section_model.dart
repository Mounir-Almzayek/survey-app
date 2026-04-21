import 'package:equatable/equatable.dart';

import '../../utils/json_parser.dart';
import 'question_model.dart';

class Section extends Equatable {
  final int id;
  final int? surveyId;
  final String? title;
  final String? description;
  final int? order;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  final List<Question>? questions;

  const Section({
    required this.id,
    this.surveyId,
    this.title,
    this.description,
    this.order,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.questions,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: JsonParser.asInt(json['id']),
      surveyId: JsonParser.asIntOrNull(json['survey_id']),
      title: JsonParser.asStringOrNull(json['title']),
      description: JsonParser.asStringOrNull(json['description']),
      order: JsonParser.asIntOrNull(json['order']),
      createdAt: JsonParser.asDateTimeOrNull(json['created_at']),
      updatedAt: JsonParser.asDateTimeOrNull(json['updated_at']),
      deletedAt: JsonParser.asDateTimeOrNull(json['deleted_at']),
      questions: JsonParser.parseList(json['questions'], Question.fromJson),
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
