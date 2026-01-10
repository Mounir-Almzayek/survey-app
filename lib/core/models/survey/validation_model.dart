import 'package:equatable/equatable.dart';
import '../../enums/survey_enums.dart';

class Validation extends Equatable {
  final int id;
  final ValidationType type;
  final String validation;
  final String enTitle;
  final String arTitle;
  final String enContent;
  final String arContent;
  final bool needsValue;
  final Map<String, dynamic>? valueFields;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const Validation({
    required this.id,
    required this.type,
    required this.validation,
    required this.enTitle,
    required this.arTitle,
    required this.enContent,
    required this.arContent,
    this.needsValue = false,
    this.valueFields,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Validation.fromJson(Map<String, dynamic> json) {
    return Validation(
      id: json['id'],
      type: ValidationType.fromJson(json['type']),
      validation: json['validation'],
      enTitle: json['en_title'],
      arTitle: json['ar_title'],
      enContent: json['en_content'],
      arContent: json['ar_content'],
      needsValue: json['needs_value'] ?? false,
      valueFields: json['value_fields'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
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
