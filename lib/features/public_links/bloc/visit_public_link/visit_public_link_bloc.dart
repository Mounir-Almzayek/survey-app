import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_runner.dart';
import '../../models/validated_public_link.dart';
import '../../repository/public_links_online_repository.dart';
import 'visit_public_link_event.dart';
import 'visit_public_link_state.dart';

/// Bloc for visiting public links
/// Uses AsyncRunner for all operations
class VisitPublicLinkBloc
    extends Bloc<VisitPublicLinkEvent, VisitPublicLinkState> {
  final AsyncRunner<ValidatedPublicLink> _visitLinkRunner =
      AsyncRunner<ValidatedPublicLink>();

  VisitPublicLinkBloc() : super(const VisitPublicLinkInitial()) {
    on<VisitPublicLink>(_onVisitPublicLink);
  }

  Future<void> _onVisitPublicLink(
    VisitPublicLink event,
    Emitter<VisitPublicLinkState> emit,
  ) async {
    emit(VisitPublicLinkLoading(shortCode: event.shortCode));

    await _visitLinkRunner.run(
      onlineTask: (_) async {
        return await PublicLinksOnlineRepository.visitPublicLink(
          event.shortCode,
        );
      },
      checkConnectivity: true,
      onSuccess: (link) {
        if (!emit.isDone) {
          emit(VisitPublicLinkSuccess(link, shortCode: event.shortCode));
        }
      },
      onError: (error) {
        if (!emit.isDone) {
          emit(VisitPublicLinkError(error.toString(), shortCode: event.shortCode));
        }
      },
    );
  }
}
