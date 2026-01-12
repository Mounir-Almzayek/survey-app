import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_runner.dart';
import '../../models/public_link.dart';
import '../../repository/public_links_local_repository.dart';
import '../../repository/public_links_repository.dart';
import 'get_my_public_links_event.dart';
import 'get_my_public_links_state.dart';

/// Bloc for fetching researcher's public links
/// Uses AsyncRunner for all operations and supports offline caching
class GetMyPublicLinksBloc
    extends Bloc<GetMyPublicLinksEvent, GetMyPublicLinksState> {
  final AsyncRunner<List<PublicLink>> _getLinksRunner =
      AsyncRunner<List<PublicLink>>();

  GetMyPublicLinksBloc() : super(const GetMyPublicLinksInitial()) {
    on<GetMyPublicLinks>(_onGetMyPublicLinks);
  }

  Future<void> _onGetMyPublicLinks(
    GetMyPublicLinks event,
    Emitter<GetMyPublicLinksState> emit,
  ) async {
    emit(
      GetMyPublicLinksLoading(
        search: event.search,
        status: event.status,
        surveyId: event.surveyId,
        ownerUserId: event.ownerUserId,
      ),
    );

    await _getLinksRunner.run(
      onlineTask: (_) async => await PublicLinksRepository.getMyPublicLinks(),
      offlineTask: (_) async =>
          await PublicLinksLocalRepository.getPublicLinks(),
      checkConnectivity: true,
      onSuccess: (links) {
        if (!emit.isDone) {
          // Filter results inside the Bloc
          final filteredLinks = links.where((link) {
            bool matches = true;
            if (event.search != null && event.search!.isNotEmpty) {
              matches =
                  matches &&
                  (link.shortCode.contains(event.search!) ||
                      link.surveyTitle.toLowerCase().contains(
                        event.search!.toLowerCase(),
                      ));
            }
            if (event.status != null && event.status!.isNotEmpty) {
              matches = matches && link.status == event.status;
            }
            if (event.surveyId != null) {
              matches = matches && link.surveyId == event.surveyId;
            }
            if (event.ownerUserId != null) {
              matches = matches && link.ownerUserId == event.ownerUserId;
            }
            return matches;
          }).toList();

          emit(
            GetMyPublicLinksSuccess(
              filteredLinks,
              search: event.search,
              status: event.status,
              surveyId: event.surveyId,
              ownerUserId: event.ownerUserId,
            ),
          );
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(
            GetMyPublicLinksError(
              error.toString(),
              search: event.search,
              status: event.status,
              surveyId: event.surveyId,
              ownerUserId: event.ownerUserId,
            ),
          );
        }
      },
    );
  }
}
