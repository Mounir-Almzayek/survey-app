import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../public_links/bloc/get_my_public_links/get_my_public_links_bloc.dart';
import '../../public_links/bloc/get_my_public_links/get_my_public_links_event.dart';
import 'home_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              GetMyPublicLinksBloc()..add(const GetMyPublicLinks()),
        ),
      ],
      child: const HomeScreen(),
    );
  }
}
