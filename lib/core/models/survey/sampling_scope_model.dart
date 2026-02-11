import 'package:equatable/equatable.dart';

/// SamplingScope Model - For sampling framework
class SamplingScope extends Equatable {
  final int id;
  final String name;
  final int sampleSize;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final List<SamplingScopeZone>? zones;
  final List<Survey>? surveys;

  const SamplingScope({
    required this.id,
    required this.name,
    required this.sampleSize,
    required this.createdAt,
    required this.updatedAt,
    this.zones,
    this.surveys,
  });

  factory SamplingScope.fromJson(Map<String, dynamic> json) {
    return SamplingScope(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      sampleSize: json['sample_size'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      zones: (json['zones'] as List?)
          ?.map((e) => SamplingScopeZone.fromJson(e))
          .toList(),
      surveys: (json['surveys'] as List?)
          ?.map((e) => Survey.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sample_size': sampleSize,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'zones': zones?.map((e) => e.toJson()).toList(),
      'surveys': surveys?.map((e) => e.toJson()).toList(),
    };
  }

  /// Get total zones count
  int get zonesCount => zones?.length ?? 0;

  /// Get total surveys count
  int get surveysCount => surveys?.length ?? 0;

  /// Check if sampling scope has zones
  bool get hasZones => zones != null && zones!.isNotEmpty;

  /// Check if sampling scope has surveys
  bool get hasSurveys => surveys != null && surveys!.isNotEmpty;

  /// Get zones names as comma-separated string
  String get zonesNames {
    if (!hasZones) return '';
    return zones!.map((zone) => zone.zone?.name ?? '').join(', ');
  }

  /// Get sample size progress (placeholder for future implementation)
  double get sampleSizeProgress =>
      0.0; // TODO: Calculate based on actual responses

  @override
  List<Object?> get props => [
    id,
    name,
    sampleSize,
    createdAt,
    updatedAt,
    zones,
    surveys,
  ];
}

/// SamplingScopeZone Model - M-to-M relationship between SamplingScope and Zone
class SamplingScopeZone extends Equatable {
  final int samplingScopeId;
  final int zoneId;
  final DateTime? createdAt;

  // Relations
  final SamplingScope? samplingScope;
  final Zone? zone;

  const SamplingScopeZone({
    required this.samplingScopeId,
    required this.zoneId,
    this.createdAt,
    this.samplingScope,
    this.zone,
  });

  factory SamplingScopeZone.fromJson(Map<String, dynamic> json) {
    return SamplingScopeZone(
      samplingScopeId: json['sampling_scope_id'] as int? ?? 0,
      zoneId: json['zone_id'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      samplingScope: json['sampling_scope'] != null
          ? SamplingScope.fromJson(json['sampling_scope'])
          : null,
      zone: json['zone'] != null ? Zone.fromJson(json['zone']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sampling_scope_id': samplingScopeId,
      'zone_id': zoneId,
      'created_at': createdAt?.toIso8601String(),
      'sampling_scope': samplingScope?.toJson(),
      'zone': zone?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    samplingScopeId,
    zoneId,
    createdAt,
    samplingScope,
    zone,
  ];
}

/// Zone Model - Geographic zones
class Zone extends Equatable {
  final int id;
  final String name;
  final String administrativeClass;
  final int level;
  final int? parentId;
  final String colorHex;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // Relations
  final Zone? parent;
  final List<Zone>? children;

  const Zone({
    required this.id,
    required this.name,
    required this.administrativeClass,
    required this.level,
    this.parentId,
    required this.colorHex,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.parent,
    this.children,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      administrativeClass: json['administrative_class'] as String? ?? '',
      level: json['level'] as int? ?? 1,
      parentId: json['parent_id'],
      colorHex: json['color_hex'] as String? ?? '#000000',
      active: json['active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'].toString())
          : null,
      parent: json['parent'] != null ? Zone.fromJson(json['parent']) : null,
      children: (json['children'] as List?)
          ?.map((e) => Zone.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'administrative_class': administrativeClass,
      'level': level,
      'parent_id': parentId,
      'color_hex': colorHex,
      'active': active,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'parent': parent?.toJson(),
      'children': children?.map((e) => e.toJson()).toList(),
    };
  }

  /// Get children count
  int get childrenCount => children?.length ?? 0;

  /// Check if zone has children
  bool get hasChildren => children != null && children!.isNotEmpty;

  /// Check if zone has parent
  bool get hasParent => parentId != null && parent != null;

  /// Get full hierarchy path
  String get hierarchyPath {
    final parts = <String>[name];
    Zone? current = parent;
    while (current != null) {
      parts.insert(0, current.name);
      current = current.parent;
    }
    return parts.join(' > ');
  }

  @override
  List<Object?> get props => [
    id,
    name,
    administrativeClass,
    level,
    parentId,
    colorHex,
    active,
    createdAt,
    updatedAt,
    deletedAt,
    parent,
    children,
  ];
}

// Forward declaration for Survey to avoid circular imports
class Survey {
  final int id;
  final String title;

  const Survey({required this.id, required this.title});

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }
}
