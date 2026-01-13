import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/assignments_list/assignments_list_bloc.dart';
import '../../bloc/start_response/start_response_bloc.dart';
import '../screens/assignments_screen.dart';

class AssignmentsPage extends StatelessWidget {
  const AssignmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AssignmentsListBloc()..add(LoadAssignments()),
        ),
        BlocProvider(create: (context) => StartResponseBloc()),
      ],
      child: const AssignmentsScreen(),
    );
  }
}
