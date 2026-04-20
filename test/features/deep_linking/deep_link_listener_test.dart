import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:king_abdulaziz_center_survey_app/core/routes/app_routes.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/bloc/deep_link_bloc.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/bloc/deep_link_event.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/config/deep_link_config.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/presentation/deep_link_listener.dart';

void main() {
  testWidgets('AwaitingDiscardConfirmation shows discard dialog', (tester) async {
    final bloc = DeepLinkBloc(isSurveyInProgress: () => true);
    final host = DeepLinkConfig.expectedHost;

    // DeepLinkListener calls GoRouter.of(context), which requires the context
    // to be a descendant of the GoRouter widget tree. Using a ShellRoute ensures
    // the listener is mounted inside the router's InheritedWidget scope.
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) => BlocProvider.value(
            value: bloc,
            child: DeepLinkListener(child: child),
          ),
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const Scaffold(body: Text('home')),
            ),
            GoRoute(
              path: Routes.surveyDeepLinkPath,
              builder: (_, __) => const Scaffold(body: Text('survey')),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    // Pump enough frames for the initial GoRouter route to build.
    await tester.pump();
    await tester.pump();

    // Drive the BLoC event and dialog rendering outside FakeAsync.
    // runAsync temporarily suspends FakeAsync so real Futures and timers work.
    // The BlocListener callback is async and awaits showDialog — if we were
    // inside FakeAsync, pump() would spin forever trying to settle that Future.
    await tester.runAsync(() async {
      bloc.add(DeepLinkReceived(Uri.parse('https://$host/survey/abc')));
      // Yield to the event loop so the BLoC stream emits
      // AwaitingDiscardConfirmation, the BlocListener receives it, and
      // showDialog is called (opening the dialog route).
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });

    // After runAsync, pump frames so Flutter renders the dialog that was pushed
    // during the async phase.
    await tester.pump();
    await tester.pump();

    expect(find.text('Discard current survey?'), findsOneWidget);

    await bloc.close();
  });
}
