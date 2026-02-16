import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/assignments_list/assignments_list_bloc.dart';
import '../../bloc/start_response/start_response_bloc.dart';
import '../screens/assignments_screen.dart';

class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({super.key});

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AssignmentsListBloc>().add(LoadAssignments());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StartResponseBloc(),
      child: const AssignmentsScreen(),
    );
  }
}
