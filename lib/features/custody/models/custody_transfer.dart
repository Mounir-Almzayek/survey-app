import 'package:equatable/equatable.dart';

/// Model representing a custody transfer request
class CustodyTransfer extends Equatable {
  final String toUserEmail;
  final String? notes;

  const CustodyTransfer({
    required this.toUserEmail,
    this.notes,
  });

  /// Create CustodyTransfer from JSON
  factory CustodyTransfer.fromJson(Map<String, dynamic> json) {
    return CustodyTransfer(
      toUserEmail: json['to_user_email'] as String,
      notes: json['notes'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'to_user_email': toUserEmail,
      if (notes != null) 'notes': notes,
    };
  }

  @override
  List<Object?> get props => [toUserEmail, notes];
}

