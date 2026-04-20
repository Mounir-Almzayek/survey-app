import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../bloc/deep_link_bloc.dart';
import '../bloc/deep_link_event.dart';
import '../bloc/deep_link_state.dart';
import '../models/device_registration_args.dart';
import '../models/survey_deep_link_args.dart';
import 'widgets/discard_survey_dialog.dart';

class DeepLinkListener extends StatelessWidget {
  final Widget child;
  const DeepLinkListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeepLinkBloc, DeepLinkState>(
      listenWhen: (p, c) => p != c,
      listener: (context, state) async {
        final router = GoRouter.of(context);
        final currentLocation =
            router.routerDelegate.currentConfiguration.uri.toString();

        switch (state) {
          case DeepLinkIdle():
            return;
          case NavigateToDeviceRegistration(:final token):
            if (currentLocation.startsWith(Routes.deviceRegistrationPath)) {
              context.read<DeepLinkBloc>().add(const NavigationHandled());
              return;
            }
            router.push(
              Routes.deviceRegistrationPath,
              extra: DeviceRegistrationArgs(token: token, fromDeepLink: true),
            );
            if (context.mounted) {
              context.read<DeepLinkBloc>().add(const NavigationHandled());
            }
          case NavigateToSurvey(:final shortCode):
            router.push(
              Routes.surveyDeepLinkPath,
              extra: SurveyDeepLinkArgs(shortCode: shortCode),
            );
            if (context.mounted) {
              context.read<DeepLinkBloc>().add(const NavigationHandled());
            }
          case AwaitingDiscardConfirmation(:final pendingShortCode):
            final confirmed = await showDiscardSurveyDialog(context);
            if (!context.mounted) return;
            if (confirmed) {
              context
                  .read<DeepLinkBloc>()
                  .add(ConfirmDiscardActiveSurvey(pendingShortCode));
            } else {
              context.read<DeepLinkBloc>().add(const CancelDiscardActiveSurvey());
            }
        }
      },
      child: child,
    );
  }
}
