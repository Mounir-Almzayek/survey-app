import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_runner.dart';
import '../../models/public_link.dart';
import '../../repository/public_links_local_repository.dart';
import '../../repository/public_links_repository.dart';
import 'get_public_link_details_event.dart';
import 'get_public_link_details_state.dart';

class GetPublicLinkDetailsBloc
    extends Bloc<GetPublicLinkDetailsEvent, GetPublicLinkDetailsState> {
  final AsyncRunner<PublicLink> _getLinkRunner = AsyncRunner<PublicLink>();

  GetPublicLinkDetailsBloc() : super(GetPublicLinkDetailsInitial()) {
    on<GetPublicLinkDetails>(_onGetPublicLinkDetails);
  }

  Future<void> _onGetPublicLinkDetails(
    GetPublicLinkDetails event,
    Emitter<GetPublicLinkDetailsState> emit,
  ) async {
    emit(GetPublicLinkDetailsLoading());

    await _getLinkRunner.run(
      onlineTask: (_) async {
        final links = await PublicLinksRepository.getMyPublicLinks();
        final link = links
            .where((l) => l.shortCode == event.shortCode)
            .firstOrNull;
        if (link == null) throw Exception('Public link not found');
        return link;
      },
      offlineTask: (_) async {
        final links = await PublicLinksLocalRepository.getPublicLinks();
        final link = links
            .where((l) => l.shortCode == event.shortCode)
            .firstOrNull;
        if (link == null) throw Exception('Public link not found');
        return link;
      },
      checkConnectivity: true,
      onSuccess: (link) {
        if (!emit.isDone) {
          emit(GetPublicLinkDetailsSuccess(link));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(GetPublicLinkDetailsError(error.toString()));
        }
      },
    );
  }
}
