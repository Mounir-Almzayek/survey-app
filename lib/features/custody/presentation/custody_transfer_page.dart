import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/custody_transfer/custody_transfer_bloc.dart';
import 'custody_transfer_screen.dart';

class CustodyTransferPage extends StatelessWidget {
  const CustodyTransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustodyTransferBloc(),
      child: const CustodyTransferScreen(),
    );
  }
}
