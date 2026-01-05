part of 'qr_scanner_bloc.dart';

abstract class QrScannerState {}

/// Initial state
class QrScannerInitial extends QrScannerState {}

/// Scanning state
class QrScannerScanning extends QrScannerState {}

/// Success state with scanned code
class QrScannerSuccess extends QrScannerState {
  final String code;
  final Map<String, dynamic>? parsedData;
  final VisitQrCode? qrCode;

  QrScannerSuccess(this.code, this.parsedData, [this.qrCode]);
}

/// Error state
class QrScannerError extends QrScannerState {
  final String error;

  QrScannerError(this.error);
}

/// Stopped state
class QrScannerStopped extends QrScannerState {}
