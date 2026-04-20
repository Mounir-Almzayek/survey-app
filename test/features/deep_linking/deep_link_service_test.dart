import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/service/deep_link_service.dart';

void main() {
  group('DeepLinkService dedup', () {
    test('drops identical URI within 2 seconds', () async {
      final controller = StreamController<Uri>();
      final service = DeepLinkService.test(
        initial: null,
        sourceStream: controller.stream,
        clock: () => DateTime(2026, 1, 1, 0, 0, 0),
      );

      final received = <Uri>[];
      final sub = service.linkStream.listen(received.add);

      final u = Uri.parse('https://example.com/a');
      controller.add(u);
      controller.add(u);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(received, [u]);
      await sub.cancel();
      await controller.close();
    });

    test('does not drop when outside window', () async {
      final controller = StreamController<Uri>();
      var now = DateTime(2026, 1, 1, 0, 0, 0);
      final service = DeepLinkService.test(
        initial: null,
        sourceStream: controller.stream,
        clock: () => now,
      );

      final received = <Uri>[];
      final sub = service.linkStream.listen(received.add);

      final u = Uri.parse('https://example.com/a');
      controller.add(u);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      now = now.add(const Duration(seconds: 3));
      controller.add(u);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(received.length, 2);
      await sub.cancel();
      await controller.close();
    });

    test('passes distinct URIs through immediately', () async {
      final controller = StreamController<Uri>();
      final service = DeepLinkService.test(
        initial: null,
        sourceStream: controller.stream,
        clock: () => DateTime(2026, 1, 1),
      );

      final received = <Uri>[];
      final sub = service.linkStream.listen(received.add);

      controller.add(Uri.parse('https://example.com/a'));
      controller.add(Uri.parse('https://example.com/b'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(received.length, 2);
      await sub.cancel();
      await controller.close();
    });
  });
}
