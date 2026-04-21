/// Defensive JSON parsing helpers.
///
/// Backend responses occasionally drift in shape (a field that's documented as
/// an object can come back as `null` or even a list under edge cases such as
/// empty surveys). The raw `as Map<String, dynamic>` cast we usually write
/// throws a hard `TypeError` when that happens, surfacing as the cryptic
/// `List<dynamic> is not a subtype of Map<String, dynamic>?` exception.
///
/// These helpers turn those casts into safe, predictable conversions: they
/// return `null` (or an empty value) instead of throwing, so model factories
/// can degrade gracefully when the wire format is off.
class JsonParser {
  const JsonParser._();

  /// Casts [value] to `Map<String, dynamic>` if it is one, otherwise returns
  /// `null`. Lists, scalars, and null all resolve to `null`.
  static Map<String, dynamic>? asMapOrNull(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  /// Casts [value] to `Map<String, dynamic>`; returns an empty map when the
  /// value is missing or has the wrong shape.
  static Map<String, dynamic> asMap(dynamic value) =>
      asMapOrNull(value) ?? const <String, dynamic>{};

  /// Casts [value] to `List<dynamic>` if it is one, otherwise returns `null`.
  /// Maps, scalars, and null all resolve to `null`.
  static List<dynamic>? asListOrNull(dynamic value) {
    if (value is List) return value;
    return null;
  }

  /// Casts [value] to `List<dynamic>`; returns an empty list when the value
  /// is missing or has the wrong shape.
  static List<dynamic> asList(dynamic value) =>
      asListOrNull(value) ?? const <dynamic>[];

  /// Parses a JSON list into typed objects via [parser]. Items that are not
  /// `Map<String, dynamic>` (or convertible) are skipped silently — never
  /// throws.
  static List<T> parseList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) parser,
  ) {
    final raw = asListOrNull(value);
    if (raw == null) return <T>[];
    return raw
        .map(asMapOrNull)
        .whereType<Map<String, dynamic>>()
        .map(parser)
        .toList(growable: false);
  }

  /// Parses a single JSON object into [T] via [parser], or `null` if the
  /// value isn't an object.
  static T? parseObject<T>(
    dynamic value,
    T Function(Map<String, dynamic>) parser,
  ) {
    final map = asMapOrNull(value);
    if (map == null) return null;
    return parser(map);
  }

  /// Reads a non-null string from [value]; returns [fallback] when missing,
  /// null, or non-string.
  static String asString(dynamic value, {String fallback = ''}) {
    if (value is String) return value;
    if (value == null) return fallback;
    return value.toString();
  }

  /// Reads a nullable string. Returns `null` for null or non-string values.
  static String? asStringOrNull(dynamic value) {
    if (value is String) return value;
    return null;
  }

  /// Reads an int; tries to coerce numeric strings. Returns [fallback] on
  /// failure.
  static int asInt(dynamic value, {int fallback = 0}) =>
      asIntOrNull(value) ?? fallback;

  /// Reads a nullable int; tries to coerce numeric strings.
  static int? asIntOrNull(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Reads a bool; treats truthy strings ("true", "1") as `true`. Returns
  /// [fallback] on failure.
  static bool asBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return fallback;
  }

  /// Reads an ISO-8601 date string; returns `null` on failure.
  static DateTime? asDateTimeOrNull(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
