import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/config/deep_link_config.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/models/deep_link.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/service/deep_link_parser.dart';

void main() {
  final host = DeepLinkConfig.expectedHost;

  group('DeepLinkParser', () {
    test('parses register-device with token', () {
      final uri = Uri.parse('https://$host/register-device?token=ABC123');
      final result = DeepLinkParser.parse(uri);
      expect(result, isA<RegisterDeviceLink>());
      expect((result as RegisterDeviceLink).token, 'ABC123');
    });

    test('parses register-device under locale prefix', () {
      final uri = Uri.parse('https://$host/ar/register-device?token=XYZ');
      final result = DeepLinkParser.parse(uri);
      expect(result, isA<RegisterDeviceLink>());
      expect((result as RegisterDeviceLink).token, 'XYZ');
    });

    test('returns UnknownLink when token is missing', () {
      final uri = Uri.parse('https://$host/register-device');
      expect(DeepLinkParser.parse(uri), isA<UnknownLink>());
    });

    test('returns UnknownLink when token is empty/whitespace', () {
      expect(DeepLinkParser.parse(Uri.parse('https://$host/register-device?token=')), isA<UnknownLink>());
      expect(DeepLinkParser.parse(Uri.parse('https://$host/register-device?token=%20')), isA<UnknownLink>());
    });

    test('parses /survey/<shortCode> (lowercased)', () {
      final uri = Uri.parse('https://$host/survey/ABC9z');
      final result = DeepLinkParser.parse(uri);
      expect(result, isA<SurveyLink>());
      expect((result as SurveyLink).shortCode, 'abc9z');
    });

    test('parses /<locale>/survey/<shortCode>', () {
      final result = DeepLinkParser.parse(Uri.parse('https://$host/en/survey/XZ9'));
      expect(result, isA<SurveyLink>());
      expect((result as SurveyLink).shortCode, 'xz9');
    });

    test('normalizes trailing slash and duplicate slashes', () {
      final result = DeepLinkParser.parse(Uri.parse('https://$host//survey//XZ9/'));
      expect(result, isA<SurveyLink>());
      expect((result as SurveyLink).shortCode, 'xz9');
    });

    test('rejects non-https scheme', () {
      expect(
        DeepLinkParser.parse(Uri.parse('http://$host/register-device?token=x')),
        isA<UnknownLink>(),
      );
    });

    test('rejects cross-host link', () {
      expect(
        DeepLinkParser.parse(Uri.parse('https://evil.example.com/register-device?token=x')),
        isA<UnknownLink>(),
      );
    });

    test('rejects empty survey shortCode', () {
      expect(DeepLinkParser.parse(Uri.parse('https://$host/survey/')), isA<UnknownLink>());
      expect(DeepLinkParser.parse(Uri.parse('https://$host/survey')), isA<UnknownLink>());
    });

    test('unknown path returns UnknownLink', () {
      expect(
        DeepLinkParser.parse(Uri.parse('https://$host/something-else')),
        isA<UnknownLink>(),
      );
    });
  });
}
