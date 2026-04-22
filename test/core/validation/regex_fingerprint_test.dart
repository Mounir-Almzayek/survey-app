import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/regex_fingerprint.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rule_registry.dart';

import '_fixtures/seeded_validations.dart';

void main() {
  test('every seeded regex fingerprints to some registered rule', () {
    // Note: ids 1/4/19/20/21 share an identical numeric-shape regex, and
    // ids 14/18 share a letters+digits+spaces pattern. The fingerprint Map
    // overwrites on duplicate keys, so those collisions resolve to the
    // last-written entry. This is acceptable because the fingerprint tier
    // is a fallback; tier-1 id lookup handles correct dispatch when the
    // backend id is known.
    for (final v in allSeededValidations) {
      final hit = RegexFingerprint.match(v.validation, RuleRegistry.rulesForTest);
      expect(hit, isNotNull,
          reason: 'no fingerprint for id=${v.id} "${v.enTitle}"');
    }
  });

  test('placeholder variants collapse to same signature', () {
    // Both patterns should fingerprint to the Minimum Length rule (id 6).
    const withPlaceholder = r'^.{min,}$';
    const withNumber = r'^.{3,}$';
    final a = RegexFingerprint.match(withPlaceholder, RuleRegistry.rulesForTest);
    final b = RegexFingerprint.match(withNumber, RuleRegistry.rulesForTest);
    expect(a?.id, 6);
    expect(b?.id, 6);
  });

  test('unknown regex returns null', () {
    final r = RegexFingerprint.match(r'^completely-unknown$', RuleRegistry.rulesForTest);
    expect(r, null);
  });

  test('null or empty pattern returns null', () {
    expect(RegexFingerprint.match(null, RuleRegistry.rulesForTest), null);
    expect(RegexFingerprint.match('', RuleRegistry.rulesForTest), null);
  });
}
