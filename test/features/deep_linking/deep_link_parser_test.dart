import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/config/deep_link_config.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/models/deep_link.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/service/deep_link_parser.dart';

import '../../helpers/test_env.dart';

void main() {
  loadTestEnv();
  final host = DeepLinkConfig.expectedHost;

  group('DeepLinkParser', () {
    group('device-registration (canonical path)', () {
      test('parses /device-registration with token', () {
        final uri = Uri.parse('https://$host/device-registration?token=ABC123');
        final result = DeepLinkParser.parse(uri);
        expect(result, isA<RegisterDeviceLink>());
        expect((result as RegisterDeviceLink).token, 'ABC123');
      });

      test('parses /{locale}/device-registration for known locale', () {
        final uri = Uri.parse('https://$host/ar/device-registration?token=XYZ');
        final result = DeepLinkParser.parse(uri);
        expect(result, isA<RegisterDeviceLink>());
        expect((result as RegisterDeviceLink).token, 'XYZ');
      });

      test('accepts arbitrary locale segment before device-registration', () {
        final uri = Uri.parse('https://$host/fr/device-registration?token=T1');
        final result = DeepLinkParser.parse(uri);
        expect(result, isA<RegisterDeviceLink>());
        expect((result as RegisterDeviceLink).token, 'T1');
      });

      test('returns UnknownLink when token is missing or empty', () {
        expect(
          DeepLinkParser.parse(Uri.parse('https://$host/device-registration')),
          isA<UnknownLink>(),
        );
        expect(
          DeepLinkParser.parse(
              Uri.parse('https://$host/device-registration?token=')),
          isA<UnknownLink>(),
        );
        expect(
          DeepLinkParser.parse(
              Uri.parse('https://$host/ar/device-registration?token=%20')),
          isA<UnknownLink>(),
        );
      });
    });

    group('register-device (legacy path, backward compatible)', () {
      test('parses /register-device with token', () {
        final uri = Uri.parse('https://$host/register-device?token=ABC123');
        final result = DeepLinkParser.parse(uri);
        expect(result, isA<RegisterDeviceLink>());
        expect((result as RegisterDeviceLink).token, 'ABC123');
      });

      test('parses /{locale}/register-device', () {
        final uri = Uri.parse('https://$host/en/register-device?token=XYZ');
        final result = DeepLinkParser.parse(uri);
        expect(result, isA<RegisterDeviceLink>());
        expect((result as RegisterDeviceLink).token, 'XYZ');
      });

      test('returns UnknownLink when token is missing', () {
        expect(
          DeepLinkParser.parse(Uri.parse('https://$host/register-device')),
          isA<UnknownLink>(),
        );
      });
    });

    group('survey', () {
      test('parses /survey/<shortCode> (lowercased)', () {
        final uri = Uri.parse('https://$host/survey/ABC9z');
        final result = DeepLinkParser.parse(uri);
        expect(result, isA<SurveyLink>());
        expect((result as SurveyLink).shortCode, 'abc9z');
      });

      test('parses /<locale>/survey/<shortCode>', () {
        final result =
            DeepLinkParser.parse(Uri.parse('https://$host/en/survey/XZ9'));
        expect(result, isA<SurveyLink>());
        expect((result as SurveyLink).shortCode, 'xz9');
      });

      test('normalizes trailing slash and duplicate slashes', () {
        final result =
            DeepLinkParser.parse(Uri.parse('https://$host//survey//XZ9/'));
        expect(result, isA<SurveyLink>());
        expect((result as SurveyLink).shortCode, 'xz9');
      });

      test('rejects empty survey shortCode', () {
        expect(DeepLinkParser.parse(Uri.parse('https://$host/survey/')),
            isA<UnknownLink>());
        expect(DeepLinkParser.parse(Uri.parse('https://$host/survey')),
            isA<UnknownLink>());
      });
    });

    group('rejections', () {
      test('rejects non-https scheme', () {
        expect(
          DeepLinkParser.parse(
              Uri.parse('http://$host/device-registration?token=x')),
          isA<UnknownLink>(),
        );
      });

      test('rejects cross-host link', () {
        expect(
          DeepLinkParser.parse(
              Uri.parse('https://evil.example.com/device-registration?token=x')),
          isA<UnknownLink>(),
        );
      });

      test('unknown path returns UnknownLink', () {
        expect(
          DeepLinkParser.parse(Uri.parse('https://$host/something-else')),
          isA<UnknownLink>(),
        );
      });
    });
  });
}
