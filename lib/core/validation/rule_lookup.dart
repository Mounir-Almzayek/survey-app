import 'package:flutter/foundation.dart';

import '../models/survey/validation_model.dart';
import 'raw_regex_rule.dart';
import 'regex_fingerprint.dart';
import 'rule.dart';

/// Four-tier dispatch chain: title -> id -> fingerprint -> raw regex.
///
/// Title is the most reliable discriminator because backend primary-key
/// IDs are per-tenant / per-seed and collide with the client's canonical
/// rule IDs (e.g. backend can send `validation_id: 1` for "Value Range"
/// while the client's id 1 is "Number"). The `en_title` field is stable
/// across backends because it's the human-readable catalog entry.
class RuleLookup {
  /// Tracks en_titles already flagged as unmapped so the per-title warning
  /// prints once per session instead of every call. Visible for tests to
  /// reset between cases.
  @visibleForTesting
  static final Set<String> loggedUnmapped = <String>{};

  static Rule? resolve(
    Validation v,
    Map<int, Rule> byId, {
    Map<String, dynamic> params = const {},
  }) {
    // Tier 1: title match. Authoritative when present.
    final titleId = _titleToId[v.enTitle?.trim()];
    if (titleId != null) {
      final rule = byId[titleId];
      if (rule != null) {
        _log('title', v);
        return rule;
      }
    }

    // Title missed — surface it loudly so missing backend titles get added
    // to _titleToId rather than silently falling through to a wrong rule.
    _warnUnmapped(v);

    // Tier 2: id match. Kept for back-compat with fixtures that seed ids
    // matching the client registry.
    final byIdHit = byId[v.id];
    if (byIdHit != null) {
      _log('id', v);
      return byIdHit;
    }

    // Tier 3: regex fingerprint, with min/max disambiguation.
    final byFp = RegexFingerprint.match(v.validation, byId);
    if (byFp != null) {
      final refined = _refineByParams(v, byFp, byId, params);
      _log(identical(refined, byFp) ? 'fingerprint' : 'fingerprint+params', v);
      return refined;
    }

    // Tier 4: run the backend-provided regex as-is.
    if ((v.validation ?? '').isNotEmpty) {
      _log('raw-regex', v);
      return RawRegexRule(v);
    }

    _log('unhandled', v);
    return null;
  }

  static void _warnUnmapped(Validation v) {
    final key = v.enTitle?.trim() ?? '';
    if (loggedUnmapped.contains(key)) return;
    loggedUnmapped.add(key);
    final displayTitle = key.isEmpty ? '(empty)' : '"$key"';
    debugPrint(
      '[ValidationUnmapped] en_title=$displayTitle id=${v.id} — '
      'not in _titleToId; add it to lib/core/validation/rule_lookup.dart '
      'to avoid ID collisions with the backend catalog.',
    );
  }

  /// Canonical en_title → client rule id. Mirrors the seeded catalog; update
  /// this map when rules are added/renamed.
  static const Map<String, int> _titleToId = {
    'Number': 1,
    'Positive Number': 2,
    'Integer (Positive or Negative)': 3,
    'Decimal Number': 4,
    'Decimal Number (2 Decimal Places)': 5,
    'Minimum Length': 6,
    'Maximum Length': 7,
    'Length Range': 8,
    'Minimum Letters': 9,
    'Maximum Letters': 10,
    'Letters Only': 11,
    'Letters and Spaces Only': 12,
    'Alphanumeric': 13,
    'Alphanumeric with Spaces': 14,
    'Email': 15,
    'URL': 16,
    'No Spaces': 17,
    'No Special Characters': 18,
    'Minimum Value': 19,
    'Maximum Value': 20,
    'Value Range': 21,
    'Arabic Text Only': 22,
    'English Text Only': 23,
    'Minimum 8 Characters': 24,
    'Strong Password': 25,
    'Minimum Selection': 26,
    'Maximum Selection': 27,
    'Minimum Date/Time': 28,
    'Maximum Date/Time': 29,
    'Between Dates/Times': 30,
    'Equal Date/Time': 34,
    'Max File Size': 31,
    'Allowed Extensions': 32,
    'Phone Number': 33,
  };

  /// Disambiguates fingerprint collisions using the validation's declared
  /// `value_fields` plus the per-question `values` map. The numeric-shape
  /// fingerprint canonicalizes ids 1/4/19/20/21 to NumberRule (id 1), and
  /// the length-shape fingerprint canonicalizes ids 6/7/8/24 to MinLengthRule
  /// (id 6) — both silently drop min/max enforcement when the backend sends
  /// an unknown id for a Min/Max/Range rule. Route to the right rule by
  /// inspecting which bounds are declared on the schema (`value_fields`) OR
  /// supplied on the question (`params`) — either is authoritative, so
  /// schemas that omit `value_fields` still disambiguate via live params.
  static Rule _refineByParams(
    Validation v,
    Rule canonical,
    Map<int, Rule> byId,
    Map<String, dynamic> params,
  ) {
    final hasMin = params.containsKey('min') ||
        v.valueFields.any((f) => f['field'] == 'min');
    final hasMax = params.containsKey('max') ||
        v.valueFields.any((f) => f['field'] == 'max');
    if (!hasMin && !hasMax) return canonical;

    switch (canonical.id) {
      case 1: // NumberRule — numeric-shape collision
        if (hasMin && hasMax) return byId[21] ?? canonical;
        if (hasMin) return byId[19] ?? canonical;
        if (hasMax) return byId[20] ?? canonical;
        break;
      case 6: // MinLengthRule — length-shape collision
        if (hasMin && hasMax) return byId[8] ?? canonical;
        if (hasMax) return byId[7] ?? canonical;
        // hasMin alone already maps to canonical (id 6).
        break;
    }
    return canonical;
  }

  static void _log(String tier, Validation v) {
    debugPrint(
      '[ValidationFallback] tier=$tier id=${v.id} title="${v.enTitle}"',
    );
  }
}
