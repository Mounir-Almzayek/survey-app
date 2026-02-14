import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../public_links/bloc/create_short_lived_link/create_short_lived_link_bloc.dart';
import '../bloc/main_navigation/main_navigation_bloc.dart';
import '../../profile/bloc/profile/profile_bloc.dart';
import '../../device_location/bloc/device_location/device_location_bloc.dart';
import 'main_screen.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MainNavigationBloc()),
        BlocProvider(create: (_) => ProfileBloc()),
        BlocProvider(create: (_) => DeviceLocationBloc()),
        BlocProvider(create: (_) => CreateShortLivedLinkBloc()),
      ],
      child: const MainScreen(),
    );
  }
}
