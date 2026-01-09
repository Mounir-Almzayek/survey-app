import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/email_verification/email_verification_bloc.dart';
import 'email_verification_screen.dart';

class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmailVerificationBloc(),
      child: const EmailVerificationScreen(),
    );
  }
}
