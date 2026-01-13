import 'package:flutter/material.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';

/// Enum representing the status of a custody record
enum CustodyStatus {
  pending,
  verified,
  cancelled;

  /// Create CustodyStatus from string
  static CustodyStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return CustodyStatus.pending;
      case 'VERIFIED':
        return CustodyStatus.verified;
      case 'CANCELLED':
        return CustodyStatus.cancelled;
      default:
        return CustodyStatus.pending;
    }
  }

  /// Convert to string
  String get stringValue {
    switch (this) {
      case CustodyStatus.pending:
        return 'PENDING';
      case CustodyStatus.verified:
        return 'VERIFIED';
      case CustodyStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Get status color
  Color get color {
    switch (this) {
      case CustodyStatus.pending:
        return AppColors.warning;
      case CustodyStatus.verified:
        return AppColors.success;
      case CustodyStatus.cancelled:
        return AppColors.error;
    }
  }

  /// Get translated label
  String label(BuildContext context) {
    final s = S.of(context);
    switch (this) {
      case CustodyStatus.pending:
        return s.custody_status_pending;
      case CustodyStatus.verified:
        return s.custody_status_verified;
      case CustodyStatus.cancelled:
        return s.custody_status_cancelled;
    }
  }

  /// Check if custody is pending
  bool get isPending => this == CustodyStatus.pending;

  /// Check if custody is verified
  bool get isVerified => this == CustodyStatus.verified;

  /// Check if custody is cancelled
  bool get isCancelled => this == CustodyStatus.cancelled;
}
