import 'package:equatable/equatable.dart';
import '../../../../core/enums/survey_enums.dart';

/// ReportSectionConfig Model - Configuration for report sections
class ReportSectionConfig extends Equatable {
  final int? id;
  final int? reportConfigId;
  final String title;
  final ResponseStatus? responseStatus;
  final List<ReportGroup>? groups;
  final List<ReportMetric>? metrics;
  final int? order;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReportSectionConfig({
    this.id,
    this.reportConfigId,
    required this.title,
    this.responseStatus,
    this.groups,
    this.metrics,
    this.order,
    this.createdAt,
    this.updatedAt,
  });

  factory ReportSectionConfig.fromJson(Map<String, dynamic> json) {
    return ReportSectionConfig(
      id: json['id'] as int?,
      reportConfigId: json['report_config_id'] as int?,
      title: json['title'] as String? ?? '',
      responseStatus: json['response_status'] != null
          ? ResponseStatus.fromJson(json['response_status'])
          : null,
      groups: (json['groups'] as List?)
          ?.map((e) => ReportGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      metrics: (json['metrics'] as List?)
          ?.map((e) => ReportMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
      order: json['order'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_config_id': reportConfigId,
      'title': title,
      'response_status': responseStatus?.toJson(),
      'groups': groups?.map((e) => e.toJson()).toList(),
      'metrics': metrics?.map((e) => e.toJson()).toList(),
      'order': order,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    reportConfigId,
    title,
    responseStatus,
    groups,
    metrics,
    order,
    createdAt,
    updatedAt,
  ];
}

/// ReportGroup Model - Groups within report sections
class ReportGroup extends Equatable {
  final int? id;
  final int? sectionId;
  final String label;
  final String? sourceType; // Zone, PhysicalDevice, Question
  final String? sourceId; // The ID of the source
  final String? sourceField; // The field name
  final int? order;

  const ReportGroup({
    this.id,
    this.sectionId,
    required this.label,
    this.sourceType,
    this.sourceId,
    this.sourceField,
    this.order,
  });

  factory ReportGroup.fromJson(Map<String, dynamic> json) {
    return ReportGroup(
      id: json['id'] as int?,
      sectionId: json['section_id'] as int?,
      label: json['label'] as String? ?? '',
      sourceType: json['source_type'] as String?,
      sourceId: json['source_id'] as String?,
      sourceField: json['source_field'] as String?,
      order: json['order'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section_id': sectionId,
      'label': label,
      'source_type': sourceType,
      'source_id': sourceId,
      'source_field': sourceField,
      'order': order,
    };
  }

  @override
  List<Object?> get props => [
    id,
    sectionId,
    label,
    sourceType,
    sourceId,
    sourceField,
    order,
  ];
}

/// ReportMetric Model - Metrics within report sections
class ReportMetric extends Equatable {
  final int? id;
  final int? sectionId;
  final String label;
  final String? sourceType; // Zone, PhysicalDevice, Question
  final String? sourceId; // The ID of the source
  final String? sourceField; // The field name
  final AggregationType? aggregation;
  final List<MetricsFilter>? filters;
  final int? order;

  const ReportMetric({
    this.id,
    this.sectionId,
    required this.label,
    this.sourceType,
    this.sourceId,
    this.sourceField,
    this.aggregation,
    this.filters,
    this.order,
  });

  factory ReportMetric.fromJson(Map<String, dynamic> json) {
    return ReportMetric(
      id: json['id'] as int?,
      sectionId: json['section_id'] as int?,
      label: json['label'] as String? ?? '',
      sourceType: json['source_type'] as String?,
      sourceId: json['source_id'] as String?,
      sourceField: json['source_field'] as String?,
      aggregation: json['aggregation'] != null
          ? AggregationType.fromJson(json['aggregation'])
          : null,
      filters: (json['filters'] as List?)
          ?.map((e) => MetricsFilter.fromJson(e as Map<String, dynamic>))
          .toList(),
      order: json['order'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section_id': sectionId,
      'label': label,
      'source_type': sourceType,
      'source_id': sourceId,
      'source_field': sourceField,
      'aggregation': aggregation?.toJson(),
      'filters': filters?.map((e) => e.toJson()).toList(),
      'order': order,
    };
  }

  @override
  List<Object?> get props => [
    id,
    sectionId,
    label,
    sourceType,
    sourceId,
    sourceField,
    aggregation,
    filters,
    order,
  ];
}

/// MetricsFilter Model - Filters for report metrics
class MetricsFilter extends Equatable {
  final String? type; // RANGE, EQ, NOT_EQ, LT, GT, LTE, GTE
  final List<String>? values;

  const MetricsFilter({
    this.type,
    this.values,
  });

  factory MetricsFilter.fromJson(Map<String, dynamic> json) {
    return MetricsFilter(
      type: json['type'] as String?,
      values: (json['values'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'values': values,
    };
  }

  @override
  List<Object?> get props => [type, values];
}
