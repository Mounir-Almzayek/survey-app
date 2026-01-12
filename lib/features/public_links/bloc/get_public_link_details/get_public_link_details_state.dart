import 'package:equatable/equatable.dart';
import '../../models/public_link.dart';

abstract class GetPublicLinkDetailsState extends Equatable {
  const GetPublicLinkDetailsState();

  @override
  List<Object?> get props => [];
}

class GetPublicLinkDetailsInitial extends GetPublicLinkDetailsState {}

class GetPublicLinkDetailsLoading extends GetPublicLinkDetailsState {}

class GetPublicLinkDetailsSuccess extends GetPublicLinkDetailsState {
  final PublicLink publicLink;

  const GetPublicLinkDetailsSuccess(this.publicLink);

  @override
  List<Object?> get props => [publicLink];
}

class GetPublicLinkDetailsError extends GetPublicLinkDetailsState {
  final String message;

  const GetPublicLinkDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
