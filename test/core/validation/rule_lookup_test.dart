import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/l10n/generated/l10n.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/raw_regex_rule.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rule_lookup.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rule_registry.dart';

import '_fixtures/seeded_validations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await S.load(const Locale('en')));

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

  group('real-backend shape: title-based dispatch (primary tier)', () {
    // Backend IDs are DB primary keys that do NOT align with the client's
    // seeded rule IDs — e.g. production sends validation_id=1 with
    // en_title="Value Range" (client id=1 is Number). The `validation`
    // regex field is also absent. Only `en_title` is dependable.
    Validation titled({
      required int id,
      required String enTitle,
      required List<Map<String, dynamic>> fields,
    }) =>
        Validation(
          id: id,
          type: ValidationType.questions,
          validation: null, // backend omits the regex string
          enTitle: enTitle,
          arTitle: 'x',
          enContent: 'x',
          arContent: 'x',
          valueFields: fields,
          isActive: true,
        );

    test('backend Value Range under id=1 → ValueRangeRule (client id 21)', () {
      final v = titled(id: 1, enTitle: 'Value Range', fields: const [
        {'field': 'min', 'type': 'number'},
        {'field': 'max', 'type': 'number'},
      ]);
      final hit = RuleLookup.resolve(v, byId, params: const {'min': 3, 'max': 10});
      expect(hit, isNotNull);
      expect(hit!.id, 21);
    });

    test('backend Minimum Length under id=5 → MinLengthRule (client id 6)', () {
      final v = titled(id: 5, enTitle: 'Minimum Length', fields: const [
        {'field': 'min', 'type': 'positive_integer'},
      ]);
      final hit = RuleLookup.resolve(v, byId, params: const {'min': 10});
      expect(hit, isNotNull);
      expect(hit!.id, 6);
    });

    test('backend Maximum Length under id=6 → MaxLengthRule (client id 7)', () {
      final v = titled(id: 6, enTitle: 'Maximum Length', fields: const [
        {'field': 'max', 'type': 'positive_integer'},
      ]);
      final hit = RuleLookup.resolve(v, byId, params: const {'max': 5000});
      expect(hit, isNotNull);
      expect(hit!.id, 7);
    });

    test('backend Length Range under id=7 → LengthRangeRule (client id 8)', () {
      final v = titled(id: 7, enTitle: 'Length Range', fields: const [
        {'field': 'min', 'type': 'positive_integer'},
        {'field': 'max', 'type': 'positive_integer'},
      ]);
      final hit = RuleLookup.resolve(v, byId, params: const {'min': 3, 'max': 10});
      expect(hit, isNotNull);
      expect(hit!.id, 8);
    });

    test('backend Letters Only under id=10 → LettersOnlyRule (client id 11)', () {
      final v = titled(id: 10, enTitle: 'Letters Only', fields: const []);
      final hit = RuleLookup.resolve(v, byId);
      expect(hit, isNotNull);
      expect(hit!.id, 11);
    });

    test('unknown title with numeric id=1 still hits client Number (id 1)', () {
      // Tier-1 title misses; tier-2 id hit preserves old behavior.
      final v = Validation(
        id: 1,
        type: ValidationType.questions,
        validation: r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$',
        enTitle: 'Completely Unknown Title',
        arTitle: 'x',
      );
      final hit = RuleLookup.resolve(v, byId);
      expect(hit, isNotNull);
      expect(hit!.id, 1);
    });

    test('unmapped title is recorded once in loggedUnmapped for later surfacing', () {
      RuleLookup.loggedUnmapped.clear();
      final v = Validation(
        id: 9999,
        type: ValidationType.questions,
        validation: null,
        enTitle: 'Max Digits (Brand New Backend Rule)',
        arTitle: 'x',
      );
      RuleLookup.resolve(v, byId);
      RuleLookup.resolve(v, byId); // second call — should NOT duplicate.
      expect(
        RuleLookup.loggedUnmapped,
        contains('Max Digits (Brand New Backend Rule)'),
      );
      expect(RuleLookup.loggedUnmapped.length, 1);
    });

    test('known title does NOT get flagged as unmapped', () {
      RuleLookup.loggedUnmapped.clear();
      final v = Validation(
        id: 1,
        type: ValidationType.questions,
        validation: null,
        enTitle: 'Value Range',
        arTitle: 'x',
      );
      RuleLookup.resolve(v, byId);
      expect(RuleLookup.loggedUnmapped, isEmpty);
    });
  });

  group('tier refinement: numeric-shape collision disambiguates by valueFields', () {
    // Regex that fingerprint maps to NumberRule (id 1) — same shape as
    // seeded ids 1/4/19/20/21. Title kept OFF the known-titles map so the
    // test exercises the fingerprint+params refinement path.
    const numericRegex = r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$';

    Validation numeric({required int id, required List<Map<String, dynamic>> fields}) =>
        Validation(
          id: id,
          type: ValidationType.questions,
          validation: numericRegex,
          enTitle: 'Custom Numeric Range Unknown',
          arTitle: 'مخصص',
          enContent: 'x',
          arContent: 'x',
          valueFields: fields,
        );

    test('unknown id + {min,max} value_fields → ValueRangeRule (id 21)', () {
      final v = numeric(id: 9999, fields: const [
        {'field': 'min', 'type': 'number'},
        {'field': 'max', 'type': 'number'},
      ]);
      final hit = RuleLookup.resolve(v, byId);
      expect(hit, isNotNull);
      expect(hit!.id, 21);
    });

    test('unknown id + {min} only → MinValueRule (id 19)', () {
      final v = numeric(id: 9999, fields: const [
        {'field': 'min', 'type': 'number'},
      ]);
      final hit = RuleLookup.resolve(v, byId);
      expect(hit, isNotNull);
      expect(hit!.id, 19);
    });

    test('unknown id + {max} only → MaxValueRule (id 20)', () {
      final v = numeric(id: 9999, fields: const [
        {'field': 'max', 'type': 'number'},
      ]);
      final hit = RuleLookup.resolve(v, byId);
      expect(hit, isNotNull);
      expect(hit!.id, 20);
    });

    test('unknown id + no value_fields → stays NumberRule (id 1)', () {
      final v = numeric(id: 9999, fields: const []);
      final hit = RuleLookup.resolve(v, byId);
      expect(hit, isNotNull);
      expect(hit!.id, 1);
    });

    test('unknown id + empty value_fields + params{min,max} → ValueRangeRule (id 21)', () {
      // Real backend sometimes omits value_fields on the Validation object
      // but still sends {min, max} in the QuestionValidation's values map —
      // disambiguation must work off actual params too.
      final v = numeric(id: 9999, fields: const []);
      final hit = RuleLookup.resolve(v, byId, params: const {'min': 3, 'max': 10});
      expect(hit, isNotNull);
      expect(hit!.id, 21);
    });

    test('unknown id + empty value_fields + params{min} only → MinValueRule (id 19)', () {
      final v = numeric(id: 9999, fields: const []);
      final hit = RuleLookup.resolve(v, byId, params: const {'min': 3});
      expect(hit, isNotNull);
      expect(hit!.id, 19);
    });

    test('unknown id + empty value_fields + params{max} only → MaxValueRule (id 20)', () {
      final v = numeric(id: 9999, fields: const []);
      final hit = RuleLookup.resolve(v, byId, params: const {'max': 10});
      expect(hit, isNotNull);
      expect(hit!.id, 20);
    });
  });

  group('tier 2 refinement: length-shape collision disambiguates by valueFields', () {
    // Regex pattern that fingerprint maps to MinLengthRule (id 6) — same
    // shape as seeded ids 6/7/8/24 (all normalize to `^.{}$`). Title kept
    // OFF the known-titles map to exercise the fingerprint+params path.
    const lengthRegex = r'^.{min,max}$';

    Validation length({required int id, required List<Map<String, dynamic>> fields}) =>
        Validation(
          id: id,
          type: ValidationType.questions,
          validation: lengthRegex,
          enTitle: 'Custom Length Range Unknown',
          arTitle: 'مخصص',
          enContent: 'x',
          arContent: 'x',
          valueFields: fields,
        );

    test('unknown id + {min,max} value_fields → LengthRangeRule (id 8)', () {
      final v = length(id: 9999, fields: const [
        {'field': 'min', 'type': 'positive_integer'},
        {'field': 'max', 'type': 'positive_integer'},
      ]);
      final hit = RuleLookup.resolve(v, byId);
      expect(hit, isNotNull);
      expect(hit!.id, 8);
    });

    test('unknown id + {max} only → MaxLengthRule (id 7)', () {
      final v = length(id: 9999, fields: const [
        {'field': 'max', 'type': 'positive_integer'},
      ]);
      final hit = RuleLookup.resolve(v, byId);
      expect(hit, isNotNull);
      expect(hit!.id, 7);
    });
  });
}
