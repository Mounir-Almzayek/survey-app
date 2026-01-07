import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/custody_list/custody_list_bloc.dart';
import '../bloc/custody_list/custody_list_event.dart';
import 'custody_list_screen.dart';

class CustodyPage extends StatelessWidget {
  const CustodyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustodyListBloc()..add(const LoadCustodyRecords()),
      child: const CustodyListScreen(),
    );
  }
}

