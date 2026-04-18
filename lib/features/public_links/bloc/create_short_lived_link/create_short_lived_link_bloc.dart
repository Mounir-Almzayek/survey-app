import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/network/api_config.dart';
import '../../../device_location/service/location_service.dart';
import '../../models/create_short_lived_link_request.dart';
import '../../repository/public_links_online_repository.dart';
import 'create_short_lived_link_event.dart';
import 'create_short_lived_link_state.dart';

/// Bloc for creating a public link with current GPS appended to URL.
class CreateShortLivedLinkBloc
    extends Bloc<CreateShortLivedLinkEvent, CreateShortLivedLinkState> {
  CreateShortLivedLinkBloc() : super(const ShortLivedLinkInitial()) {
    on<InitializeShortLinkRequestFromSurvey>(_onInitializeFromSurvey);
    on<CreateShortLivedLinkRequested>(_onCreateShortLivedLinkRequested);
  }

  void _onInitializeFromSurvey(
    InitializeShortLinkRequestFromSurvey event,
    Emitter<CreateShortLivedLinkState> emit,
  ) {
    final survey = event.survey;
    final request = CreateShortLivedLinkRequest(surveyId: survey.id);
    emit(
      ShortLivedLinkInitial(
        request: request,
        surveyLanguage: survey.lang,
      ),
    );
  }

  Future<void> _onCreateShortLivedLinkRequested(
    CreateShortLivedLinkRequested event,
    Emitter<CreateShortLivedLinkState> emit,
  ) async {
    final request = state.request ?? const CreateShortLivedLinkRequest();
    emit(
      ShortLivedLinkLoading(
        request: request,
        surveyLanguage: state.surveyLanguage,
      ),
    );

    try {
      final hasPermission = await LocationService.hasPermissions();
      if (!hasPermission) {
        final granted = await LocationService.requestPermissions();
        if (!granted) {
          if (!isClosed) {
            emit(
              ShortLivedLinkError(
                'Location permission is required to create the link',
                request: request,
                surveyLanguage: state.surveyLanguage,
              ),
            );
          }
          return;
        }
      }

      final location = await LocationService.getCurrentLocation();
      final lat = location.latitude;
      final lng = location.longitude;

      final result = await PublicLinksOnlineRepository.createShortLived(
        body: request.toJson(),
      );

      final fullUrl = APIConfig.buildShortLivedSurveyUrl(
        result.shortCode,
        lat,
        lng,
        locale: state.surveyLanguage,
      );

      if (!isClosed) {
        emit(
          ShortLivedLinkReady(
            fullUrl: fullUrl,
            shortCode: result.shortCode,
            request: request,
            surveyLanguage: state.surveyLanguage,
          ),
        );
      }
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      if (!isClosed) {
        emit(
          ShortLivedLinkError(
            message,
            request: request,
            surveyLanguage: state.surveyLanguage,
          ),
        );
      }
    }
  }
}
