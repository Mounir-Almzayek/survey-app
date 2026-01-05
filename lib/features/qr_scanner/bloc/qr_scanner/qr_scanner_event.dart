part of 'qr_scanner_bloc.dart';

abstract class QrScannerEvent {}

/// Event to start scanning
class StartScanning extends QrScannerEvent {}

/// Event to stop scanning
class StopScanning extends QrScannerEvent {}

/// Event when QR code is detected
class QrCodeDetected extends QrScannerEvent {
  final String code;

  QrCodeDetected(this.code);
}

/// Event to reset scanner
class ResetScanner extends QrScannerEvent {}
