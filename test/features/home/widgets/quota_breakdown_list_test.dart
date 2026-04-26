// test/features/home/widgets/quota_breakdown_list_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/home/models/survey_stats_model.dart';
import 'package:king_abdulaziz_center_survey_app/features/home/presentation/widgets/quota_breakdown_list.dart';

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, __) => MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('renders top-N entries with display_label + progress/target', (tester) async {
    final entries = List.generate(
      8,
      (i) => QuotaBreakdownEntry(
        quotaTargetId: i + 1,
        displayLabel: 'الكوتا $i',
        progress: i * 2,
        target: 10,
        progressPercent: i * 20,
      ),
    );
    await tester.pumpWidget(_wrap(QuotaBreakdownList(entries: entries, topN: 5)));
    await tester.pumpAndSettle();
    expect(find.text('الكوتا 0'), findsOneWidget);
    expect(find.text('الكوتا 4'), findsOneWidget);
    expect(find.text('الكوتا 5'), findsNothing);
    expect(find.text('عرض المزيد'), findsOneWidget);
  });

  testWidgets('tap "show more" reveals all entries', (tester) async {
    final entries = List.generate(
      8,
      (i) => QuotaBreakdownEntry(
        quotaTargetId: i,
        displayLabel: 'X $i',
        progress: 0,
        target: 10,
        progressPercent: 0,
      ),
    );
    await tester.pumpWidget(_wrap(QuotaBreakdownList(entries: entries, topN: 5)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('عرض المزيد'));
    await tester.pumpAndSettle();
    expect(find.text('X 7'), findsOneWidget);
  });

  testWidgets('hides toggle when entries count <= topN', (tester) async {
    final entries = List.generate(
      3,
      (i) => QuotaBreakdownEntry(
        quotaTargetId: i,
        displayLabel: 'الكوتا $i',
        progress: 0,
        target: 10,
        progressPercent: 0,
      ),
    );
    await tester.pumpWidget(_wrap(QuotaBreakdownList(entries: entries, topN: 5)));
    await tester.pumpAndSettle();
    expect(find.text('عرض المزيد'), findsNothing);
    expect(find.text('الكوتا 0'), findsOneWidget);
    expect(find.text('الكوتا 2'), findsOneWidget);
  });
}
