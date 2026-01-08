/// Permission Model
class Permission {
  final int id;
  final String enName;
  final String? enDescription;
  final String? arDescription;
  final String? arName;
  final String code;
  final String? enAction;
  final String? arAction;
  final int? permissionRoleId;
  final int? permissionCategoryId;

  const Permission({
    required this.id,
    required this.enName,
    this.enDescription,
    this.arDescription,
    this.arName,
    required this.code,
    this.enAction,
    this.arAction,
    this.permissionRoleId,
    this.permissionCategoryId,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] as int? ?? 0,
      enName: json['en_name'] as String? ?? '',
      enDescription: json['en_description'] as String?,
      arDescription: json['ar_description'] as String?,
      arName: json['ar_name'] as String?,
      code: json['code'] as String? ?? '',
      enAction: json['en_action'] as String?,
      arAction: json['ar_action'] as String?,
      permissionRoleId: json['permission_role_id'] as int?,
      permissionCategoryId: json['permission_category_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'en_name': enName,
      'en_description': enDescription,
      'ar_description': arDescription,
      'ar_name': arName,
      'code': code,
      'en_action': enAction,
      'ar_action': arAction,
      'permission_role_id': permissionRoleId,
      'permission_category_id': permissionCategoryId,
    };
  }
}

/// UserType Model
class UserType {
  final int id;
  final String name;
  final String enName;
  final String arName;
  final String? enDescription;
  final String? arDescription;
  final List<Permission> permissions;

  const UserType({
    required this.id,
    required this.name,
    required this.enName,
    required this.arName,
    this.enDescription,
    this.arDescription,
    this.permissions = const [],
  });

  factory UserType.fromJson(Map<String, dynamic> json) {
    return UserType(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      enName: json['en_name'] as String? ?? '',
      arName: json['ar_name'] as String? ?? '',
      enDescription: json['en_description'] as String?,
      arDescription: json['ar_description'] as String?,
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => Permission.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'en_name': enName,
      'ar_name': arName,
      'en_description': enDescription,
      'ar_description': arDescription,
      'permissions': permissions.map((e) => e.toJson()).toList(),
    };
  }
}

/// User Model
class User {
  final int id;
  final String name;
  final String email;
  final bool confirmedEmail;
  final String? emailConfirmationCode;
  final bool active;
  final String? resetPasswordCode;
  final String? resetPasswordCodeExpiresAt;
  final bool available;
  final String language;
  final String? lastLoginAt;
  final String? timezone;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final List<UserType> userTypes;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.confirmedEmail = false,
    this.emailConfirmationCode,
    this.active = true,
    this.resetPasswordCode,
    this.resetPasswordCodeExpiresAt,
    this.available = false,
    this.language = 'AR',
    this.lastLoginAt,
    this.timezone,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.userTypes = const [],
  });

  /// Helper method to safely convert dynamic value to int?
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed;
    }
    return null;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id']) ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      confirmedEmail: json['confirmed_email'] as bool? ?? false,
      emailConfirmationCode: json['email_confirmation_code'] as String?,
      active: json['active'] as bool? ?? true,
      resetPasswordCode: json['reset_password_code'] as String?,
      resetPasswordCodeExpiresAt:
          json['reset_password_code_expires_at'] as String?,
      available: json['available'] as bool? ?? false,
      language: json['language'] as String? ?? 'AR',
      lastLoginAt: json['last_login_at'] as String?,
      timezone: json['timezone']?.toString(),
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      deletedAt: json['deleted_at'] as String?,
      userTypes:
          (json['user_types'] as List<dynamic>?)
              ?.map((e) => UserType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'confirmed_email': confirmedEmail,
      'email_confirmation_code': emailConfirmationCode,
      'active': active,
      'reset_password_code': resetPasswordCode,
      'reset_password_code_expires_at': resetPasswordCodeExpiresAt,
      'available': available,
      'language': language,
      'last_login_at': lastLoginAt,
      'timezone': timezone,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'user_types': userTypes.map((e) => e.toJson()).toList(),
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    bool? confirmedEmail,
    String? emailConfirmationCode,
    bool? active,
    String? resetPasswordCode,
    String? resetPasswordCodeExpiresAt,
    bool? available,
    String? language,
    String? lastLoginAt,
    String? timezone,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    List<UserType>? userTypes,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      confirmedEmail: confirmedEmail ?? this.confirmedEmail,
      emailConfirmationCode:
          emailConfirmationCode ?? this.emailConfirmationCode,
      active: active ?? this.active,
      resetPasswordCode: resetPasswordCode ?? this.resetPasswordCode,
      resetPasswordCodeExpiresAt:
          resetPasswordCodeExpiresAt ?? this.resetPasswordCodeExpiresAt,
      available: available ?? this.available,
      language: language ?? this.language,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userTypes: userTypes ?? this.userTypes,
    );
  }
}
