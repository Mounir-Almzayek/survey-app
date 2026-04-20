import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/assignment/bloc/survey_by_short_code/survey_by_short_code_bloc.dart';
import 'package:king_abdulaziz_center_survey_app/features/assignment/bloc/survey_by_short_code/survey_by_short_code_event.dart';
import 'package:king_abdulaziz_center_survey_app/features/assignment/bloc/survey_by_short_code/survey_by_short_code_state.dart';
import 'package:king_abdulaziz_center_survey_app/features/public_links/models/validated_public_link.dart';

void main() {
  const fakeLink = ValidatedPublicLink(
    surveyTitle: 't',
    surveyDescription: 'd',
    greetingMessage: 'g',
    requireLocation: false,
  );

  group('SurveyByShortCodeBloc', () {
    blocTest<SurveyByShortCodeBloc, SurveyByShortCodeState>(
      'FetchSurvey success -> Loading -> Loaded',
      build: () => SurveyByShortCodeBloc(
        fetcher: (_) async => SurveyFetchOutcome.success(fakeLink),
        listenConnectivity: false,
      ),
      act: (b) => b.add(const FetchSurvey('abc')),
      expect: () => [
        const SurveyByShortCodeLoading('abc'),
        isA<SurveyByShortCodeLoaded>()
            .having((s) => s.shortCode, 'shortCode', 'abc'),
      ],
    );

    blocTest<SurveyByShortCodeBloc, SurveyByShortCodeState>(
      'offline -> Error(offline)',
      build: () => SurveyByShortCodeBloc(
        fetcher: (_) async => SurveyFetchOutcome.offline(),
        listenConnectivity: false,
      ),
      act: (b) => b.add(const FetchSurvey('abc')),
      expect: () => [
        const SurveyByShortCodeLoading('abc'),
        const SurveyByShortCodeError('abc', SurveyFetchErrorKind.offline),
      ],
    );

    blocTest<SurveyByShortCodeBloc, SurveyByShortCodeState>(
      'notFound -> Error(notFound)',
      build: () => SurveyByShortCodeBloc(
        fetcher: (_) async => SurveyFetchOutcome.notFound(),
        listenConnectivity: false,
      ),
      act: (b) => b.add(const FetchSurvey('abc')),
      expect: () => [
        const SurveyByShortCodeLoading('abc'),
        const SurveyByShortCodeError('abc', SurveyFetchErrorKind.notFound),
      ],
    );

    blocTest<SurveyByShortCodeBloc, SurveyByShortCodeState>(
      'duplicate FetchSurvey while Loading is a no-op',
      build: () => SurveyByShortCodeBloc(
        fetcher: (_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return SurveyFetchOutcome.success(fakeLink);
        },
        listenConnectivity: false,
      ),
      act: (b) async {
        b.add(const FetchSurvey('abc'));
        b.add(const FetchSurvey('abc'));
        await Future.delayed(const Duration(milliseconds: 100));
      },
      expect: () => [
        const SurveyByShortCodeLoading('abc'),
        isA<SurveyByShortCodeLoaded>(),
      ],
    );

    blocTest<SurveyByShortCodeBloc, SurveyByShortCodeState>(
      'ConnectivityRestored while Error(offline) auto-retries',
      build: () {
        var attempt = 0;
        return SurveyByShortCodeBloc(
          fetcher: (_) async {
            attempt++;
            if (attempt == 1) return SurveyFetchOutcome.offline();
            return SurveyFetchOutcome.success(fakeLink);
          },
          listenConnectivity: false,
        );
      },
      act: (b) async {
        b.add(const FetchSurvey('abc'));
        await Future.delayed(const Duration(milliseconds: 10));
        b.add(const ConnectivityRestored());
      },
      expect: () => [
        const SurveyByShortCodeLoading('abc'),
        const SurveyByShortCodeError('abc', SurveyFetchErrorKind.offline),
        const SurveyByShortCodeLoading('abc'),
        isA<SurveyByShortCodeLoaded>(),
      ],
    );
  });
}
