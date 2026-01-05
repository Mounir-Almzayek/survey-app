import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/visit_qr_code.dart';

part 'qr_scanner_event.dart';
part 'qr_scanner_state.dart';

/// QR Scanner BLoC
/// Manages QR code scanning state and events
class QrScannerBloc extends Bloc<QrScannerEvent, QrScannerState> {
  QrScannerBloc() : super(QrScannerInitial()) {
    on<StartScanning>(_onStartScanning);
    on<StopScanning>(_onStopScanning);
    on<QrCodeDetected>(_onQrCodeDetected);
    on<ResetScanner>(_onResetScanner);
  }

  void _onStartScanning(StartScanning event, Emitter<QrScannerState> emit) {
    emit(QrScannerScanning());
  }

  void _onStopScanning(StopScanning event, Emitter<QrScannerState> emit) {
    emit(QrScannerStopped());
  }

  void _onQrCodeDetected(QrCodeDetected event, Emitter<QrScannerState> emit) {
    // Return the code as-is without any parsing or validation
    // This allows any text to be scanned and returned
    emit(QrScannerSuccess(event.code, null, null));
  }

  void _onResetScanner(ResetScanner event, Emitter<QrScannerState> emit) {
    emit(QrScannerInitial());
  }
}
