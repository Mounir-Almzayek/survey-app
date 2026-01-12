import 'package:equatable/equatable.dart';
import '../../models/public_link.dart';

/// States for Get My Public Links Bloc
abstract class GetMyPublicLinksState extends Equatable {
  final String? search;
  final String? status;
  final int? surveyId;
  final int? ownerUserId;

  const GetMyPublicLinksState({
    this.search,
    this.status,
    this.surveyId,
    this.ownerUserId,
  });

  @override
  List<Object?> get props => [search, status, surveyId, ownerUserId];
}

/// Initial state
class GetMyPublicLinksInitial extends GetMyPublicLinksState {
  const GetMyPublicLinksInitial({
    super.search,
    super.status,
    super.surveyId,
    super.ownerUserId,
  });
}

/// Loading state
class GetMyPublicLinksLoading extends GetMyPublicLinksState {
  const GetMyPublicLinksLoading({
    super.search,
    super.status,
    super.surveyId,
    super.ownerUserId,
  });
}

/// Success state for a list of links
class GetMyPublicLinksSuccess extends GetMyPublicLinksState {
  final List<PublicLink> links;

  const GetMyPublicLinksSuccess(
    this.links, {
    super.search,
    super.status,
    super.surveyId,
    super.ownerUserId,
  });

  @override
  List<Object?> get props => [links, ...super.props];
}

/// Error state
class GetMyPublicLinksError extends GetMyPublicLinksState {
  final String message;

  const GetMyPublicLinksError(
    this.message, {
    super.search,
    super.status,
    super.surveyId,
    super.ownerUserId,
  });

  @override
  List<Object?> get props => [message, ...super.props];
}
