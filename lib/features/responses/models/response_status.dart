enum ResponseStatus {
  draft,
  submitted,
  flagged,
  rejected,
}

extension ResponseStatusX on ResponseStatus {
  static ResponseStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'SUBMITTED':
        return ResponseStatus.submitted;
      case 'FLAGGED':
        return ResponseStatus.flagged;
      case 'REJECTED':
        return ResponseStatus.rejected;
      case 'DRAFT':
      default:
        return ResponseStatus.draft;
    }
  }

  String get apiValue {
    switch (this) {
      case ResponseStatus.draft:
        return 'DRAFT';
      case ResponseStatus.submitted:
        return 'SUBMITTED';
      case ResponseStatus.flagged:
        return 'FLAGGED';
      case ResponseStatus.rejected:
        return 'REJECTED';
    }
  }
}


