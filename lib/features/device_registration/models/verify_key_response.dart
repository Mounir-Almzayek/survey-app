class VerifyKeyResponse {
  final bool valid;
  final int? physicalDeviceId;
  final DateTime? expiresAt;
  final DateTime? lastUsedAt;

  const VerifyKeyResponse({
    required this.valid,
    this.physicalDeviceId,
    this.expiresAt,
    this.lastUsedAt,
  });

  factory VerifyKeyResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    
    return VerifyKeyResponse(
      valid: json['valid'] as bool? ?? false,
      physicalDeviceId: data?['physicalDeviceId'] as int?,
      expiresAt: data?['expiresAt'] != null
          ? DateTime.parse(data!['expiresAt'] as String)
          : null,
      lastUsedAt: data?['lastUsedAt'] != null
          ? DateTime.parse(data!['lastUsedAt'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'valid': valid,
      if (physicalDeviceId != null) 'physicalDeviceId': physicalDeviceId,
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt!.toIso8601String(),
    };
  }
}

