import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/bloc/deep_link_bloc.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/bloc/deep_link_event.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/bloc/deep_link_state.dart';
import 'package:king_abdulaziz_center_survey_app/features/deep_linking/config/deep_link_config.dart';

import '../../helpers/test_env.dart';

void main() {
  loadTestEnv();
  final host = DeepLinkConfig.expectedHost;

  DeepLinkBloc make({bool surveyInProgress = false}) => DeepLinkBloc(
        isSurveyInProgress: () => surveyInProgress,
      );

  group('DeepLinkBloc', () {
    blocTest<DeepLinkBloc, DeepLinkState>(
      'register-device -> NavigateToDeviceRegistration',
      build: () => make(),
      act: (b) => b.add(DeepLinkReceived(Uri.parse('https://$host/register-device?token=abc'))),
      expect: () => [const NavigateToDeviceRegistration('abc')],
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'survey link with no active survey -> NavigateToSurvey',
      build: () => make(),
      act: (b) => b.add(DeepLinkReceived(Uri.parse('https://$host/survey/xyz'))),
      expect: () => [const NavigateToSurvey('xyz')],
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'survey link while active survey -> AwaitingDiscardConfirmation',
      build: () => make(surveyInProgress: true),
      act: (b) => b.add(DeepLinkReceived(Uri.parse('https://$host/survey/xyz'))),
      expect: () => [const AwaitingDiscardConfirmation('xyz')],
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'confirm discard -> NavigateToSurvey',
      build: () => make(surveyInProgress: true),
      seed: () => const AwaitingDiscardConfirmation('xyz'),
      act: (b) => b.add(const ConfirmDiscardActiveSurvey('xyz')),
      expect: () => [const NavigateToSurvey('xyz')],
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'cancel discard -> Idle',
      build: () => make(surveyInProgress: true),
      seed: () => const AwaitingDiscardConfirmation('xyz'),
      act: (b) => b.add(const CancelDiscardActiveSurvey()),
      expect: () => [const DeepLinkIdle()],
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'last-link-wins: new link while awaiting confirmation supersedes',
      build: () => make(surveyInProgress: true),
      seed: () => const AwaitingDiscardConfirmation('old'),
      act: (b) => b.add(DeepLinkReceived(Uri.parse('https://$host/survey/new'))),
      expect: () => [const AwaitingDiscardConfirmation('new')],
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'unknown link does not emit',
      build: () => make(),
      act: (b) => b.add(DeepLinkReceived(Uri.parse('https://evil.example.com/x'))),
      expect: () => <DeepLinkState>[],
    );

    blocTest<DeepLinkBloc, DeepLinkState>(
      'NavigationHandled clears nav state',
      build: () => make(),
      seed: () => const NavigateToSurvey('xyz'),
      act: (b) => b.add(const NavigationHandled()),
      expect: () => [const DeepLinkIdle()],
    );
  });
}
