import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../public_links/models/validated_public_link.dart';
import '../../../public_links/repository/public_links_online_repository.dart';
import 'survey_by_short_code_event.dart';
import 'survey_by_short_code_state.dart';

class SurveyFetchOutcome {
  final ValidatedPublicLink? data;
  final SurveyFetchErrorKind? error;
  const SurveyFetchOutcome._(this.data, this.error);
  factory SurveyFetchOutcome.success(ValidatedPublicLink data) =>
      SurveyFetchOutcome._(data, null);
  factory SurveyFetchOutcome.offline() =>
      const SurveyFetchOutcome._(null, SurveyFetchErrorKind.offline);
  factory SurveyFetchOutcome.notFound() =>
      const SurveyFetchOutcome._(null, SurveyFetchErrorKind.notFound);
  factory SurveyFetchOutcome.serverError() =>
      const SurveyFetchOutcome._(null, SurveyFetchErrorKind.serverError);
}

typedef SurveyFetcher = Future<SurveyFetchOutcome> Function(String shortCode);

class SurveyByShortCodeBloc
    extends Bloc<SurveyByShortCodeEvent, SurveyByShortCodeState> {
  final SurveyFetcher fetcher;
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  SurveyByShortCodeBloc({SurveyFetcher? fetcher, bool listenConnectivity = true})
      : fetcher = fetcher ?? _defaultFetcher,
        super(const SurveyByShortCodeIdle()) {
    on<FetchSurvey>(_onFetch);
    on<RetrySurveyFetch>(_onRetry);
    on<ConnectivityRestored>(_onConnectivity);

    if (listenConnectivity) {
      _connSub = Connectivity().onConnectivityChanged.listen((results) {
        final online = results.any((r) => r != ConnectivityResult.none);
        if (online) add(const ConnectivityRestored());
      });
    }
  }

  Future<void> _onFetch(
      FetchSurvey event, Emitter<SurveyByShortCodeState> emit) async {
    final current = state;
    if (current is SurveyByShortCodeLoading &&
        current.shortCode == event.shortCode) {
      return;
    }
    if (current is SurveyByShortCodeLoaded &&
        current.shortCode == event.shortCode) {
      return;
    }

    emit(SurveyByShortCodeLoading(event.shortCode));
    final outcome = await fetcher(event.shortCode);
    if (outcome.data != null) {
      emit(SurveyByShortCodeLoaded(event.shortCode, outcome.data!));
    } else {
      emit(SurveyByShortCodeError(event.shortCode, outcome.error!));
    }
  }

  Future<void> _onRetry(
      RetrySurveyFetch event, Emitter<SurveyByShortCodeState> emit) async {
    final s = state;
    if (s is SurveyByShortCodeError) {
      add(FetchSurvey(s.shortCode));
    }
  }

  Future<void> _onConnectivity(
      ConnectivityRestored event, Emitter<SurveyByShortCodeState> emit) async {
    final s = state;
    if (s is SurveyByShortCodeError && s.kind == SurveyFetchErrorKind.offline) {
      add(FetchSurvey(s.shortCode));
    }
  }

  @override
  Future<void> close() {
    _connSub?.cancel();
    return super.close();
  }

  static Future<SurveyFetchOutcome> _defaultFetcher(String code) async {
    try {
      final data =
          await PublicLinksOnlineRepository.getPublicSurveyByShortCode(code);
      return SurveyFetchOutcome.success(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return SurveyFetchOutcome.offline();
      }
      if (e.response?.statusCode == 404) return SurveyFetchOutcome.notFound();
      return SurveyFetchOutcome.serverError();
    } catch (_) {
      return SurveyFetchOutcome.serverError();
    }
  }
}
