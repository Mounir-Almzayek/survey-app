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

  testWidgets('renders every segment of a multi-coordinate display_label', (tester) async {
    final entries = [
      const QuotaBreakdownEntry(
        quotaTargetId: 1,
        displayLabel: 'منطقة الباحة • مدينة مقر إمارة المنطقة • ذكر • 18-29',
        progress: 4,
        target: 10,
        progressPercent: 40,
      ),
    ];
    await tester.pumpWidget(_wrap(QuotaBreakdownList(entries: entries, topN: 5)));
    await tester.pumpAndSettle();
    // Each coordinate segment becomes its own Text widget so the layout
    // wraps gracefully regardless of how many coordinates the server sends.
    expect(find.text('منطقة الباحة'), findsOneWidget);
    expect(find.text('مدينة مقر إمارة المنطقة'), findsOneWidget);
    expect(find.text('ذكر'), findsOneWidget);
    expect(find.text('18-29'), findsOneWidget);
    expect(find.text('4/10'), findsOneWidget);
  });

  testWidgets('handles large N (6 coordinates) without truncation', (tester) async {
    final entries = [
      const QuotaBreakdownEntry(
        quotaTargetId: 1,
        displayLabel: 'A • B • C • D • E • F',
        progress: 0,
        target: 10,
        progressPercent: 0,
      ),
    ];
    await tester.pumpWidget(_wrap(QuotaBreakdownList(entries: entries, topN: 5)));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
    expect(find.text('F'), findsOneWidget);
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
