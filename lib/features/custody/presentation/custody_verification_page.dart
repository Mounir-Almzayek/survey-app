import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/custody_verification/custody_verification_bloc.dart';
import 'custody_verification_screen.dart';

class CustodyVerificationPage extends StatelessWidget {
  final int custodyId;

  const CustodyVerificationPage({super.key, required this.custodyId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustodyVerificationBloc(),
      child: CustodyVerificationScreen(custodyId: custodyId),
    );
  }
}
