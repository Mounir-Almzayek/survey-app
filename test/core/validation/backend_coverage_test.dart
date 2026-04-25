import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/l10n/generated/l10n.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/validation_model.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/raw_regex_rule.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rule_lookup.dart';
import 'package:king_abdulaziz_center_survey_app/core/validation/rule_registry.dart';

/// Locks in the Flutter ↔ backend rule-coverage contract.
///
/// **Source of truth:** `survey-system/prisma/seeders/validations.ts` lists
/// every rule the backend can attach to a question. If the backend sends a
/// title we don't recognize, [RuleLookup] either misroutes (collision) or
/// falls back to [RawRegexRule] / unhandled — both of which silently degrade
/// the user-facing validation message.
///
/// This test re-asserts the entire seeded catalog by `en_title`. Adding a
/// new rule to the backend without updating Flutter will fail this test.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await S.load(const Locale('en')));

  /// All en_titles currently active in the backend seeder. Manually mirrored
  /// from `survey-system/prisma/seeders/validations.ts`. Comment-blocks for
  /// commented-out rules (Phone, Date YYYY-MM-DD, Time HH:MM) are NOT
  /// included — those are not seeded.
  const backendTitles = <String>[
    // Numeric
    'Number',
    'Positive Number',
    'Integer (Positive or Negative)',
    'Decimal Number',
    'Decimal Number (2 Decimal Places)',
    // Length
    'Minimum Length',
    'Maximum Length',
    'Length Range',
    // Letters
    'Minimum Letters',
    'Maximum Letters',
    'Letters Only',
    'Letters and Spaces Only',
    // Alphanumeric
    'Alphanumeric',
    'Alphanumeric with Spaces',
    // Format
    'Email',
    'URL',
    // Date/time
    'Minimum Date/Time',
    'Maximum Date/Time',
    'Between Dates/Times',
    'Equal Date/Time',
    // Other text
    'No Spaces',
    'No Special Characters',
    // Value range
    'Minimum Value',
    'Maximum Value',
    'Value Range',
    // Script
    'Arabic Text Only',
    'English Text Only',
    // Password
    'Minimum 8 Characters',
    'Strong Password',
  ];

  Validation titledOnly(String enTitle) => Validation(
        id: 9999, // Force a non-matching id so tier-1 (title) is the only path.
        type: ValidationType.questions,
        validation: null,
        enTitle: enTitle,
        arTitle: 'x',
        isActive: true,
      );

  group('Backend rule coverage — every seeded en_title resolves to a typed Rule', () {
    for (final title in backendTitles) {
      test('"$title" routes via title to a typed (non-RawRegex) Rule', () {
        final rule = RuleLookup.resolve(
          titledOnly(title),
          RuleRegistry.rulesForTest,
        );
        expect(rule, isNotNull,
            reason: '"$title" did not resolve to any Rule — add it to '
                'lib/core/validation/rule_lookup.dart _titleToId.');
        expect(rule, isNot(isA<RawRegexRule>()),
            reason: '"$title" resolved to RawRegexRule — that means '
                '_titleToId knows the title but the registry has no '
                'matching id. Wire up the rule class in '
                'lib/core/validation/rule_registry.dart.');
      });
    }
  });

  group('Flutter-only rules (not in backend seeder, kept for future use)', () {
    // These rules exist in the Flutter registry but the backend doesn't seed
    // them. They activate only when the backend sends a Validation with a
    // matching title — currently it never does. Listed here so the team
    // notices if the backend later starts seeding any of them.
    const flutterOnlyTitles = <String>[
      'Minimum Selection',
      'Maximum Selection',
      'Max File Size',
      'Allowed Extensions',
      'Phone Number', // commented out in backend seed; Flutter applies it
                     // implicitly for `phone_number` question type via
                     // SurveyValidator.validatePhone.
    ];

    for (final title in flutterOnlyTitles) {
      test('"$title" is registered in Flutter (latent until backend seeds it)',
          () {
        final rule = RuleLookup.resolve(
          titledOnly(title),
          RuleRegistry.rulesForTest,
        );
        expect(rule, isNotNull);
        expect(rule, isNot(isA<RawRegexRule>()));
      });
    }
  });
}
