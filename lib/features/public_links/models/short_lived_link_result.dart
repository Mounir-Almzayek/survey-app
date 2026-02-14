import 'package:equatable/equatable.dart';

/// Result of creating a short-lived public link.
/// Returned by POST /researcher/public-link/short-lived.
class ShortLivedLinkResult extends Equatable {
  final String shortCode;
  final DateTime? expiresAt;

  const ShortLivedLinkResult({
    required this.shortCode,
    this.expiresAt,
  });

  factory ShortLivedLinkResult.fromJson(Map<String, dynamic> json) {
    final expiresAtStr = json['expires_at'] as String?;
    return ShortLivedLinkResult(
      shortCode: json['short_code'] as String? ?? '',
      expiresAt: expiresAtStr != null
          ? DateTime.tryParse(expiresAtStr)
          : null,
    );
  }

  @override
  List<Object?> get props => [shortCode, expiresAt];
}
