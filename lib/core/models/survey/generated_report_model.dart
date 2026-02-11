import 'package:equatable/equatable.dart';
import '../../../../core/enums/survey_enums.dart';

/// GeneratedReport Model - Generated reports from configurations
class GeneratedReport extends Equatable {
  final int? id;
  final int? reportConfigId;
  final String? filePath;
  final ReportFormat? fileType;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final DateTime? createdAt;

  const GeneratedReport({
    this.id,
    this.reportConfigId,
    this.filePath,
    this.fileType,
    this.periodStart,
    this.periodEnd,
    this.createdAt,
  });

  factory GeneratedReport.fromJson(Map<String, dynamic> json) {
    return GeneratedReport(
      id: json['id'] as int?,
      reportConfigId: json['report_config_id'] as int?,
      filePath: json['file_path'] as String?,
      fileType: json['file_type'] != null
          ? ReportFormat.fromJson(json['file_type'])
          : null,
      periodStart: json['period_start'] != null
          ? DateTime.tryParse(json['period_start'].toString())
          : null,
      periodEnd: json['period_end'] != null
          ? DateTime.tryParse(json['period_end'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_config_id': reportConfigId,
      'file_path': filePath,
      'file_type': fileType?.toJson(),
      'period_start': periodStart?.toIso8601String(),
      'period_end': periodEnd?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    reportConfigId,
    filePath,
    fileType,
    periodStart,
    periodEnd,
    createdAt,
  ];
}
