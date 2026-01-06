import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/async_runner.dart';
import '../../models/public_link.dart';
import '../../repository/public_links_online_repository.dart';
import '../../repository/public_links_local_repository.dart';
import 'load_public_links_event.dart';
import 'load_public_links_state.dart';

/// Bloc for loading public links
/// Uses AsyncRunner for all operations
class LoadPublicLinksBloc extends Bloc<LoadPublicLinksEvent, LoadPublicLinksState> {
  final AsyncRunner<List<PublicLink>> _loadLinksRunner = AsyncRunner<List<PublicLink>>();

  LoadPublicLinksBloc() : super(const LoadPublicLinksInitial()) {
    on<LoadPublicLinks>(_onLoadPublicLinks);
    on<RefreshPublicLinks>(_onRefreshPublicLinks);
  }

  Future<void> _onLoadPublicLinks(
    LoadPublicLinks event,
    Emitter<LoadPublicLinksState> emit,
  ) async {
    if (!event.forceRefresh) {
      // Try to load from local first
      final localLinks = await PublicLinksLocalRepository.getPublicLinks();
      if (localLinks.isNotEmpty) {
        emit(LoadPublicLinksLoaded(links: localLinks, isOffline: true));
      }
    }

    emit(const LoadPublicLinksLoading());

    await _loadLinksRunner.run(
      onlineTask: (_) async {
        return await PublicLinksOnlineRepository.getPublicLinks();
      },
      offlineTask: (_) async {
        final links = await PublicLinksLocalRepository.getPublicLinks();
        if (links.isEmpty) {
          throw Exception('No local data available');
        }
        return links;
      },
      checkConnectivity: true,
      onSuccess: (links) async {
        // Save to local storage
        await PublicLinksLocalRepository.savePublicLinks(links);
        
        if (!emit.isDone) {
          emit(LoadPublicLinksLoaded(links: links, isOffline: false));
        }
      },
      onOffline: (links) {
        if (!emit.isDone) {
          emit(LoadPublicLinksLoaded(links: links, isOffline: true));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(LoadPublicLinksError(error.toString()));
        }
      },
    );
  }

  Future<void> _onRefreshPublicLinks(
    RefreshPublicLinks event,
    Emitter<LoadPublicLinksState> emit,
  ) async {
    add(const LoadPublicLinks(forceRefresh: true));
  }
}

