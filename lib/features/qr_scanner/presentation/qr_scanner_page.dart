import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/qr_scanner/qr_scanner_bloc.dart';
import 'qr_scanner_screen.dart';

/// QR Scanner Page
/// Entry point for QR Scanner feature
class QrScannerPage extends StatelessWidget {
  /// If true, returns the scanned code as string instead of navigating to visit details
  final bool returnCodeOnly;

  const QrScannerPage({
    super.key,
    this.returnCodeOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QrScannerBloc()..add(StartScanning()),
      child: QrScannerScreen(returnCodeOnly: returnCodeOnly),
    );
  }
}
