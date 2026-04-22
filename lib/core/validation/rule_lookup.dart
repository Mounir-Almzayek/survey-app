import 'package:flutter/foundation.dart';

import '../models/survey/validation_model.dart';
import 'raw_regex_rule.dart';
import 'regex_fingerprint.dart';
import 'rule.dart';

/// Three-tier dispatch chain: id -> fingerprint -> raw regex.
class RuleLookup {
  static Rule? resolve(Validation v, Map<int, Rule> byId) {
    final byIdHit = byId[v.id];
    if (byIdHit != null) return byIdHit;

    final byFp = RegexFingerprint.match(v.validation, byId);
    if (byFp != null) {
      _log('fingerprint', v);
      return byFp;
    }

    if ((v.validation ?? '').isNotEmpty) {
      _log('raw-regex', v);
      return RawRegexRule(v);
    }

    _log('unhandled', v);
    return null;
  }

  static void _log(String tier, Validation v) {
    debugPrint(
      '[ValidationFallback] tier=$tier id=${v.id} title="${v.enTitle}"',
    );
  }
}
