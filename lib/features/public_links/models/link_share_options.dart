import 'package:equatable/equatable.dart';

/// Model representing share options for a public link
class LinkShareOptions extends Equatable {
  final bool includeQRCode;
  final String? customMessage;
  final String? subject;

  const LinkShareOptions({
    this.includeQRCode = true,
    this.customMessage,
    this.subject,
  });

  @override
  List<Object?> get props => [includeQRCode, customMessage, subject];
}

