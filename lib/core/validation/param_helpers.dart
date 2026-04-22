/// Returns an int from [params] under [key], tolerating int, double, or
/// numeric-string source values. Returns null for missing/null/unparseable.
int? paramInt(Map<String, dynamic> params, String key) {
  final v = params[key];
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

/// Returns a double from [params] under [key], tolerating double, int, or
/// numeric-string source values. Returns null for missing/null/unparseable.
double? paramDouble(Map<String, dynamic> params, String key) {
  final v = params[key];
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}
