import 'package:equatable/equatable.dart';

/// Events for Get My Public Links Bloc
abstract class GetMyPublicLinksEvent extends Equatable {
  const GetMyPublicLinksEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch researcher's public links with optional filtering
class GetMyPublicLinks extends GetMyPublicLinksEvent {
  final String? search;
  final String? status;
  final int? surveyId;
  final int? ownerUserId;

  const GetMyPublicLinks({
    this.search,
    this.status,
    this.surveyId,
    this.ownerUserId,
  });

  @override
  List<Object?> get props => [search, status, surveyId, ownerUserId];
}
