import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/response_details/response_details_bloc.dart';
import 'response_details_screen.dart';

class ResponseDetailsPage extends StatelessWidget {
  final int responseId;

  const ResponseDetailsPage({super.key, required this.responseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ResponseDetailsBloc()
            ..add(LoadResponseDetails(responseId: responseId)),
      child: const ResponseDetailsScreen(),
    );
  }
}
