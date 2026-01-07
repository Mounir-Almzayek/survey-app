import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/assigned_surveys/assigned_surveys_bloc.dart';
import 'assigned_surveys_screen.dart';

class AssignedSurveysPage extends StatelessWidget {
  const AssignedSurveysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AssignedSurveysBloc(),
      child: const Scaffold(
        body: SafeArea(
          child: AssignedSurveysScreen(),
        ),
      ),
    );
  }
}


