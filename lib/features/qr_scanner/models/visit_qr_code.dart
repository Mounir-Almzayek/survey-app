import 'dart:convert';

/// Visit QR Code Model
/// Represents the QR code data for a visit
class VisitQrCode {
  final int visitId;
  final int visitorId;

  const VisitQrCode({required this.visitId, required this.visitorId});

  /// Create VisitQrCode from JSON
  factory VisitQrCode.fromJson(Map<String, dynamic> json) {
    return VisitQrCode(
      visitId: json['visit_id'] as int? ?? json['visitId'] as int? ?? 0,
      visitorId: json['visitor_id'] as int? ?? json['visitorId'] as int? ?? 0,
    );
  }

  /// Convert VisitQrCode to JSON
  Map<String, dynamic> toJson() {
    return {'visit_id': visitId, 'visitor_id': visitorId};
  }

  /// Convert VisitQrCode to JSON string (for QR code generation)
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create VisitQrCode from JSON string
  factory VisitQrCode.fromJsonString(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return VisitQrCode.fromJson(json);
    } catch (e) {
      throw FormatException('Invalid QR code format: $e');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VisitQrCode &&
        other.visitId == visitId &&
        other.visitorId == visitorId;
  }

  @override
  int get hashCode => visitId.hashCode ^ visitorId.hashCode;

  @override
  String toString() {
    return 'VisitQrCode(visitId: $visitId, visitorId: $visitorId)';
  }
}
