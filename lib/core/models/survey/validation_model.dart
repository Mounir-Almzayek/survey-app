import 'package:equatable/equatable.dart';

import '../../enums/survey_enums.dart';
import '../../utils/json_parser.dart';

/// Validation rule definition (e.g. "Minimum Length", "Email format").
///
/// Backend `value_fields` is an **array of field-spec objects**, e.g.
/// ```json
/// "value_fields": [
///   {"type": "positive_integer", "field": "min", "ar_title": "..."}
/// ]
/// ```
/// — typing this as `Map<String, dynamic>?` causes a runtime
/// `List<dynamic> is not a subtype of Map<String, dynamic>?` error on
/// implicit assignment, which is what we hit before this fix.
class Validation extends Equatable {
  final int id;
  final ValidationType type;
  final String? validation;
  final String? enTitle;
  final String? arTitle;
  final String? enContent;
  final String? arContent;
  final bool? needsValue;

  /// Specs for the parameter inputs of this rule (one entry per param,
  /// e.g. `min`/`max`). Empty when the rule has no configurable params.
  final List<Map<String, dynamic>> valueFields;

  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const Validation({
    required this.id,
    required this.type,
    this.validation,
    this.enTitle,
    this.arTitle,
    this.enContent,
    this.arContent,
    this.needsValue,
    this.valueFields = const [],
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Validation.fromJson(Map<String, dynamic> json) {
    return Validation(
      id: JsonParser.asInt(json['id']),
      type: json['type'] != null
          ? ValidationType.fromJson(json['type'])
          : ValidationType.questions,
      validation: JsonParser.asStringOrNull(json['validation']),
      enTitle: JsonParser.asStringOrNull(json['en_title']),
      arTitle: JsonParser.asStringOrNull(json['ar_title']),
      enContent: JsonParser.asStringOrNull(json['en_content']),
      arContent: JsonParser.asStringOrNull(json['ar_content']),
      needsValue: json['needs_value'] is bool ? json['needs_value'] as bool : null,
      valueFields: JsonParser.parseList<Map<String, dynamic>>(
        json['value_fields'],
        (m) => m,
      ),
      isActive: json['is_active'] is bool ? json['is_active'] as bool : null,
      createdAt: JsonParser.asDateTimeOrNull(json['created_at']),
      updatedAt: JsonParser.asDateTimeOrNull(json['updated_at']),
      deletedAt: JsonParser.asDateTimeOrNull(json['deleted_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toJson(),
      'validation': validation,
      'en_title': enTitle,
      'ar_title': arTitle,
      'en_content': enContent,
      'ar_content': arContent,
      'needs_value': needsValue,
      'value_fields': valueFields,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        validation,
        enTitle,
        arTitle,
        enContent,
        arContent,
        needsValue,
        valueFields,
        isActive,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
