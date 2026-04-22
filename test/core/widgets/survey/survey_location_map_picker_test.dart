import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/core/l10n/generated/l10n.dart';
import 'package:king_abdulaziz_center_survey_app/core/widgets/survey/survey_location_map_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../helpers/test_env.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: const [S.delegate],
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: Scaffold(body: child),
      ),
    );

void main() {
  setUpAll(loadTestEnv);

  testWidgets('renders coordinates after value is set', (tester) async {
    await tester.pumpWidget(_wrap(SurveyLocationMapPicker(
      value: const LatLng(24.72169, 46.75702),
      onChanged: (_) {},
      showCurrentLocationButton: false,
    )));
    await tester.pump();
    expect(find.textContaining('24.72169'), findsOneWidget);
    expect(find.textContaining('46.75702'), findsOneWidget);
  });

  testWidgets('renders without value and exposes "use my location" button',
      (tester) async {
    await tester.pumpWidget(_wrap(SurveyLocationMapPicker(
      value: null,
      onChanged: (_) {},
    )));
    await tester.pump();
    expect(find.byKey(const ValueKey('map-use-my-location')), findsOneWidget);
  });
}
