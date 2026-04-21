import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../bloc/answering/public_link_answering_state.dart' show
    PublicLinkAnsweringErrorKind;

/// Error scaffold shown for terminal/unrecoverable failures during start or
/// section submission. Wraps [ErrorStateWidget] with the right icon + copy.
class AnsweringErrorView extends StatelessWidget {
  final PublicLinkAnsweringErrorKind kind;
  final String fallbackMessage;
  final String surveyTitle;
  final VoidCallback onRetry;

  const AnsweringErrorView({
    super.key,
    required this.kind,
    required this.fallbackMessage,
    required this.surveyTitle,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final (message, icon) = switch (kind) {
      PublicLinkAnsweringErrorKind.offline => (
          s.no_internet_connection,
          Icons.wifi_off_rounded,
        ),
      PublicLinkAnsweringErrorKind.server => (
          s.something_went_wrong,
          Icons.cloud_off_rounded,
        ),
      PublicLinkAnsweringErrorKind.unknown => (
          fallbackMessage.isEmpty ? s.something_went_wrong : fallbackMessage,
          Icons.error_outline_rounded,
        ),
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          surveyTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        centerTitle: true,
      ),
      body: ErrorStateWidget(
        message: message,
        icon: icon,
        onRetry: onRetry,
      ),
    );
  }
}
