import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/raw_regex_rule.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rule_lookup.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rule_registry.dart';

import '_fixtures/seeded_validations.dart';

void main() {
  final byId = RuleRegistry.rulesForTest;

  test('tier 1: ID match wins when id is in the registry', () {
    final hit = RuleLookup.resolve(vNumber, byId);
    expect(hit, isNotNull);
    expect(hit!.id, 1);
  });

  test('tier 2: fingerprint match when id is unknown but regex is known', () {
    final unknownId = Validation(
      id: 9999,
      type: ValidationType.questions,
      validation: vNumber.validation,
      enTitle: 'shifted by reseed',
      arTitle: 'shifted by reseed',
      enContent: 'x',
      arContent: 'x',
    );
    final hit = RuleLookup.resolve(unknownId, byId);
    expect(hit, isNotNull);
    expect(hit!.id, 1); // Fingerprint routed to Number (id 1).
  });

  test('tier 3: RawRegexRule when neither id nor fingerprint matches', () {
    final unknown = Validation(
      id: 9999,
      type: ValidationType.questions,
      validation: r'^xyzzy$',
      enTitle: 'unknown',
      arTitle: 'unknown',
    );
    final hit = RuleLookup.resolve(unknown, byId);
    expect(hit, isA<RawRegexRule>());
  });

  test('returns null when everything is unusable', () {
    final empty = Validation(
      id: 9999,
      type: ValidationType.questions,
      validation: null,
      enTitle: 'empty',
      arTitle: 'empty',
    );
    final hit = RuleLookup.resolve(empty, byId);
    expect(hit, null);
  });
}
