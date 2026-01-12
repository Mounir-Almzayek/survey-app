import 'package:equatable/equatable.dart';

abstract class GetPublicLinkDetailsEvent extends Equatable {
  const GetPublicLinkDetailsEvent();

  @override
  List<Object?> get props => [];
}

class GetPublicLinkDetails extends GetPublicLinkDetailsEvent {
  final String shortCode;

  const GetPublicLinkDetails(this.shortCode);

  @override
  List<Object?> get props => [shortCode];
}
