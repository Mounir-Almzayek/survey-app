/// Normalizes user input into a value suitable for the HTTP `Origin` header.
/// Returns null if empty or invalid.
String? normalizeOriginForHeader(String? raw) {
  if (raw == null) return null;
  var s = raw.trim();
  if (s.isEmpty) return null;
  if (!s.contains('://')) {
    s = 'https://$s';
  }
  final uri = Uri.tryParse(s);
  if (uri == null) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  if (uri.host.isEmpty) return null;
  return uri.origin;
}
