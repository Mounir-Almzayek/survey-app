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

  /// Check if custody is pending
  bool get isPending => this == CustodyStatus.pending;

  /// Check if custody is verified
  bool get isVerified => this == CustodyStatus.verified;

  /// Check if custody is cancelled
  bool get isCancelled => this == CustodyStatus.cancelled;
}

