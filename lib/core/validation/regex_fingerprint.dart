import 'rule.dart';

/// Fallback dispatch: matches a backend regex against canonical signatures
/// of the 25 seeded rules. Normalization collapses any `{…}` quantifier
/// (placeholder or literal digits) and whitespace so structurally equivalent
/// patterns like `^.{min,}$`, `^.{3,}$`, and `^.{8,}$` all share one
/// signature.
///
/// Where multiple seeded rules share a signature (length quantifiers map to
/// 6/7/8/24; numeric-shape to 1/4/19/20/21; alphanumeric+spaces to 14/18),
/// the fingerprint table picks one canonical rule per signature. The other
/// ids still resolve via tier-1 id lookup; the fingerprint tier is only
/// consulted when the backend id is unknown to the registry.
class RegexFingerprint {
  static Rule? match(String? pattern, Map<int, Rule> byId) {
    if (pattern == null || pattern.isEmpty) return null;
    final sig = _normalize(pattern);
    final id = _signatureToId[sig];
    if (id == null) return null;
    return byId[id];
  }

  static String _normalize(String p) => p
      .replaceAll(RegExp(r'\{[^}]*\}'), '{}')
      .replaceAll(RegExp(r'\s+'), '')
      .toLowerCase();

  static final Map<String, int> _signatureToId = {
    // Numeric-shape: ids 1/4/19/20/21 collide; canonicalize to id 1 (Number).
    _normalize(r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$'): 1,
    _normalize(r'^\+?[1-9١-٩][0-9٠-٩]*$'): 2,
    _normalize(r'^[-+]?[0-9٠-٩]+$'): 3,
    _normalize(r'^[-+]?[0-9٠-٩]+\.[0-9٠-٩]{2}$'): 5,
    // Length quantifier: ids 6/7/8/24 all collapse to `^.{}$`; canonicalize
    // to id 6 (MinLength).
    _normalize(r'^.{min,}$'): 6,
    _normalize('^(?!.*[٠-٩])(?!.*[0-9])[؀-ٰٟ-ۿa-zA-Z]{min,}\$'): 9,
    _normalize('^(?!.*[٠-٩])(?!.*[0-9])[؀-ٰٟ-ۿa-zA-Z]{0,max}\$'): 10,
    _normalize('^(?!.*[٠-٩])[؀-ٰٟ-ۿa-zA-Z]+\$'): 11,
    _normalize('^(?!.*[٠-٩])[؀-ٰٟ-ۿa-zA-Z ]+\$'): 12,
    _normalize('^[؀-ۿa-zA-Z0-9٠-٩]+\$'): 13,
    // Alphanumeric+spaces: ids 14/18 collide; canonicalize to id 14.
    _normalize('^[؀-ۿa-zA-Z0-9٠-٩\\s]+\$'): 14,
    _normalize('^[a-zA-Z0-9٠-٩._%+-]+@[a-zA-Z0-9٠-٩.-]+\\.[a-zA-Z]{2,}\$'): 15,
    _normalize(r'^(https?://)?([\da-z٠-٩.-]+)\.([a-z.]{2,6})([/\w .-]*)*/?$'): 16,
    _normalize(r'^\S+$'): 17,
    _normalize(r'^(?=.*[؀-ۿ])[؀-ۿ٠-٩\s‌‍\x21-\x2F\x3A-\x40\x5B-\x60\x7B-\x7E]+$'): 22,
    _normalize(r'^[\x00-\x7F]+$'): 23,
    _normalize(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9٠-٩])(?=.*[!@#$%^&*]).{8,}$'): 25,
  };
}
