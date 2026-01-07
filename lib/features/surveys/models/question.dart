import 'package:equatable/equatable.dart';

import 'question_option.dart';

/// Question type enum matching backend QuestionTypeSchema
/// Values: 'RADIO','CHECKBOX','DROPDOWN','TEXT_SHORT','TEXT_LONG','NUMBER',
/// 'DATE','TIME','DATETIME','FILE','RATING','SLIDER','GPS'
enum QuestionType {
  radio,
  checkbox,
  dropdown,
  textShort,
  textLong,
  number,
  date,
  time,
  dateTime,
  file,
  rating,
  slider,
  gps,
}

extension QuestionTypeX on QuestionType {
  static QuestionType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'RADIO':
        return QuestionType.radio;
      case 'CHECKBOX':
        return QuestionType.checkbox;
      case 'DROPDOWN':
        return QuestionType.dropdown;
      case 'TEXT_SHORT':
        return QuestionType.textShort;
      case 'TEXT_LONG':
        return QuestionType.textLong;
      case 'NUMBER':
        return QuestionType.number;
      case 'DATE':
        return QuestionType.date;
      case 'TIME':
        return QuestionType.time;
      case 'DATETIME':
        return QuestionType.dateTime;
      case 'FILE':
        return QuestionType.file;
      case 'RATING':
        return QuestionType.rating;
      case 'SLIDER':
        return QuestionType.slider;
      case 'GPS':
        return QuestionType.gps;
      default:
        return QuestionType.textShort;
    }
  }

  String get apiValue {
    switch (this) {
      case QuestionType.radio:
        return 'RADIO';
      case QuestionType.checkbox:
        return 'CHECKBOX';
      case QuestionType.dropdown:
        return 'DROPDOWN';
      case QuestionType.textShort:
        return 'TEXT_SHORT';
      case QuestionType.textLong:
        return 'TEXT_LONG';
      case QuestionType.number:
        return 'NUMBER';
      case QuestionType.date:
        return 'DATE';
      case QuestionType.time:
        return 'TIME';
      case QuestionType.dateTime:
        return 'DATETIME';
      case QuestionType.file:
        return 'FILE';
      case QuestionType.rating:
        return 'RATING';
      case QuestionType.slider:
        return 'SLIDER';
      case QuestionType.gps:
        return 'GPS';
    }
  }
}

/// Question model matching backend QuestionWithRelations (simplified)
class Question extends Equatable {
  final int id;
  final int? sectionId;
  final QuestionType type;
  final String label;
  final String helpText;
  final bool isRequired;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<QuestionOption> options;

  const Question({
    required this.id,
    required this.sectionId,
    required this.type,
    required this.label,
    required this.helpText,
    required this.isRequired,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.options = const [],
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['question_options'] ?? json['options'];
    return Question(
      id: json['id'] as int,
      sectionId: json['section_id'] as int?,
      type: QuestionTypeX.fromString(json['type'] as String? ?? 'TEXT_SHORT'),
      label: json['label'] as String? ?? '',
      helpText: json['help_text'] as String? ?? '',
      isRequired: json['is_required'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      options: optionsJson is List
          ? optionsJson
              .map(
                (o) => QuestionOption.fromJson(o as Map<String, dynamic>),
              )
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section_id': sectionId,
      'type': type.apiValue,
      'label': label,
      'help_text': helpText,
      'is_required': isRequired,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'question_options': options.map((o) => o.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        sectionId,
        type,
        label,
        helpText,
        isRequired,
        order,
        createdAt,
        updatedAt,
        deletedAt,
        options,
      ];
}


