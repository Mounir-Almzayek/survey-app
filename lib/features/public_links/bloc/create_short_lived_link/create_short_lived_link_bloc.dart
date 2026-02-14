import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/network/api_config.dart';
import '../../../device_location/service/location_service.dart';
import '../../models/create_short_lived_link_request.dart';
import '../../repository/public_links_online_repository.dart';
import 'create_short_lived_link_event.dart';
import 'create_short_lived_link_state.dart';

/// Bloc for creating a short-lived public link with current GPS appended to URL.
class CreateShortLivedLinkBloc
    extends Bloc<CreateShortLivedLinkEvent, CreateShortLivedLinkState> {
  CreateShortLivedLinkBloc() : super(const ShortLivedLinkInitial()) {
    on<InitializeShortLinkRequestFromSurvey>(_onInitializeFromSurvey);
    on<UpdateShortLinkRequestSurveyId>(_onUpdateShortLinkRequestSurveyId);
    on<UpdateShortLinkRequestDuration>(_onUpdateShortLinkRequestDuration);
    on<UpdateShortLinkRequestDurationMinutes>(
      _onUpdateShortLinkRequestDurationMinutes,
    );
    on<CreateShortLivedLinkRequested>(_onCreateShortLivedLinkRequested);
  }

  void _onInitializeFromSurvey(
    InitializeShortLinkRequestFromSurvey event,
    Emitter<CreateShortLivedLinkState> emit,
  ) {
    final survey = event.survey;
    final now = DateTime.now();
    int? maxMinutes;
    Duration initialDuration = const Duration(minutes: 1);

    if (survey.availabilityEndAt != null) {
      final remaining = survey.availabilityEndAt!.difference(now);
      if (remaining.inMinutes >= 1) {
        maxMinutes = remaining.inMinutes;
        initialDuration = Duration(minutes: 60.clamp(1, maxMinutes));
      }
    }

    final request = CreateShortLivedLinkRequest(
      surveyId: survey.id,
      duration: initialDuration,
    );
    emit(
      ShortLivedLinkInitial(request: request, maxDurationMinutes: maxMinutes),
    );
  }

  void _onUpdateShortLinkRequestSurveyId(
    UpdateShortLinkRequestSurveyId event,
    Emitter<CreateShortLivedLinkState> emit,
  ) {
    final request = state.request ?? const CreateShortLivedLinkRequest();
    emit(
      ShortLivedLinkInitial(
        request: request.copyWith(surveyId: event.surveyId),
        maxDurationMinutes: state.maxDurationMinutes,
      ),
    );
  }

  void _onUpdateShortLinkRequestDuration(
    UpdateShortLinkRequestDuration event,
    Emitter<CreateShortLivedLinkState> emit,
  ) {
    final request = state.request ?? const CreateShortLivedLinkRequest();
    final maxMinutes = state.maxDurationMinutes;
    final minutes = maxMinutes != null
        ? event.duration.inMinutes.clamp(1, maxMinutes)
        : event.duration.inMinutes.clamp(1, 525600);
    final duration = Duration(minutes: minutes);
    emit(
      ShortLivedLinkInitial(
        request: request.copyWith(duration: duration),
        maxDurationMinutes: maxMinutes,
      ),
    );
  }

  void _onUpdateShortLinkRequestDurationMinutes(
    UpdateShortLinkRequestDurationMinutes event,
    Emitter<CreateShortLivedLinkState> emit,
  ) {
    _onUpdateShortLinkRequestDuration(
      UpdateShortLinkRequestDuration(Duration(minutes: event.minutes)),
      emit,
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
        maxDurationMinutes: state.maxDurationMinutes,
      ),
    );

    try {
      // 1. Get current location (so link has researcher's latest GPS)
      final hasPermission = await LocationService.hasPermissions();
      if (!hasPermission) {
        final granted = await LocationService.requestPermissions();
        if (!granted) {
          if (!isClosed) {
            emit(
              ShortLivedLinkError(
                'Location permission is required to create the link',
                request: request,
                maxDurationMinutes: state.maxDurationMinutes,
              ),
            );
          }
          return;
        }
      }

      final location = await LocationService.getCurrentLocation();
      final lat = location.latitude;
      final lng = location.longitude;

      // 2. Create short-lived link via API using request body from model
      final result = await PublicLinksOnlineRepository.createShortLived(
        body: request.toJson(),
      );

      // 3. Build full URL with latitude/longitude for frontend
      final base = APIConfig.surveyFrontendBaseUrl;
      final path = '/survey/${result.shortCode}';
      final query = '?latitude=$lat&longitude=$lng';
      final fullUrl = '$base$path$query';

      if (!isClosed) {
        emit(
          ShortLivedLinkReady(
            fullUrl: fullUrl,
            shortCode: result.shortCode,
            expiresAt: DateTime.now().add(request.duration),
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
            maxDurationMinutes: state.maxDurationMinutes,
          ),
        );
      }
    }
  }
}
