import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/load_public_links/load_public_links_bloc.dart';
import '../bloc/load_public_links/load_public_links_event.dart';
import '../bloc/validate_public_link/validate_public_link_bloc.dart';
import 'public_links_screen.dart';

class PublicLinksPage extends StatelessWidget {
  const PublicLinksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LoadPublicLinksBloc()..add(const LoadPublicLinks()),
        ),
        BlocProvider(create: (_) => ValidatePublicLinkBloc()),
      ],
      child: const PublicLinksScreen(),
    );
  }
}
