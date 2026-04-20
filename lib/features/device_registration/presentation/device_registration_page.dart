import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/device_info/device_info_bloc.dart';
import '../bloc/device_info/device_info_event.dart';
import '../bloc/validate_token/validate_token_bloc.dart';
import '../bloc/complete_registration/complete_registration_bloc.dart';
import 'device_registration_screen.dart';

class DeviceRegistrationPage extends StatelessWidget {
  final String? token;
  final bool fromDeepLink;

  const DeviceRegistrationPage({
    super.key,
    this.token,
    this.fromDeepLink = false,
  });

  @override
  Widget build(BuildContext context) {
    final registrationToken = token ?? '';

    if (registrationToken.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Device Registration')),
        body: const Center(child: Text('Token is required')),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              DeviceInfoBloc()..add(LoadDeviceInfo(context: context)),
        ),
        BlocProvider(create: (context) => ValidateTokenBloc()),
        BlocProvider(create: (context) => CompleteRegistrationBloc()),
      ],
      child: DeviceRegistrationScreen(
        token: registrationToken,
        fromDeepLink: fromDeepLink,
      ),
    );
  }
}
