import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/deep_link.dart';
import '../service/deep_link_parser.dart';
import 'deep_link_event.dart';
import 'deep_link_state.dart';

typedef SurveyInProgressCheck = bool Function();

class DeepLinkBloc extends Bloc<DeepLinkEvent, DeepLinkState> {
  final SurveyInProgressCheck isSurveyInProgress;

  DeepLinkBloc({required this.isSurveyInProgress}) : super(const DeepLinkIdle()) {
    on<DeepLinkReceived>(_onReceived);
    on<ConfirmDiscardActiveSurvey>(_onConfirm);
    on<CancelDiscardActiveSurvey>(_onCancel);
    on<NavigationHandled>((_, emit) => emit(const DeepLinkIdle()));
  }

  void _onReceived(DeepLinkReceived event, Emitter<DeepLinkState> emit) {
    final link = DeepLinkParser.parse(event.uri);
    switch (link) {
      case RegisterDeviceLink(:final token):
        emit(NavigateToDeviceRegistration(token));
      case SurveyLink(:final shortCode):
        if (isSurveyInProgress()) {
          emit(AwaitingDiscardConfirmation(shortCode));
        } else {
          emit(NavigateToSurvey(shortCode));
        }
      case UnknownLink():
        return;
    }
  }

  void _onConfirm(ConfirmDiscardActiveSurvey event, Emitter<DeepLinkState> emit) {
    emit(NavigateToSurvey(event.shortCode));
  }

  void _onCancel(CancelDiscardActiveSurvey event, Emitter<DeepLinkState> emit) {
    emit(const DeepLinkIdle());
  }
}
