import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/utils/responsive_layout.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../../../core/widgets/custom_elevated_button.dart';
import '../bloc/qr_scanner/qr_scanner_bloc.dart';

/// QR Scanner Screen
/// Highly efficient and visually appealing QR code scanner
class QrScannerScreen extends StatefulWidget {
  /// If true, returns the scanned code as string instead of navigating to visit details
  final bool returnCodeOnly;

  const QrScannerScreen({super.key, this.returnCodeOnly = false});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
    formats: [BarcodeFormat.qrCode],
  );

  bool _hasPermission = false;
  bool _isCheckingPermission = true;
  bool _isProcessingResult = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_hasPermission) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _controller.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _controller.stop();
        break;
      default:
        break;
    }
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (mounted) {
      if (status.isGranted) {
        setState(() {
          _hasPermission = true;
          _isCheckingPermission = false;
        });
      } else {
        setState(() {
          _hasPermission = false;
          _isCheckingPermission = false;
        });
      }
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (mounted) {
      if (status.isGranted) {
        setState(() {
          _hasPermission = true;
        });
      } else if (status.isPermanentlyDenied) {
        if (mounted) {
          UnifiedSnackbar.error(
            context,
            message: S.of(context).camera_permission_required,
          );
          openAppSettings();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          locale.qr_scanner,
          style: TextStyle(
            fontSize: context.adaptiveFont(20.sp),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: _isCheckingPermission
          ? const Center(child: LoadingWidget(withPadding: false))
          : !_hasPermission
          ? _buildPermissionRequest(locale)
          : BlocConsumer<QrScannerBloc, QrScannerState>(
              listener: (context, state) {
                if (state is QrScannerSuccess) {
                  _handleScanSuccess(context, state);
                } else if (state is QrScannerError) {
                  UnifiedSnackbar.error(context, message: state.error);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      context.read<QrScannerBloc>().add(ResetScanner());
                    }
                  });
                }
              },
              builder: (context, state) {
                return Stack(
                  children: [
                    // Camera View
                    MobileScanner(
                      controller: _controller,
                      onDetect: (capture) {
                        if (_isProcessingResult) return;
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          final barcode = barcodes.first;
                          if (barcode.rawBytes != null ||
                              barcode.rawValue != null) {
                            context.read<QrScannerBloc>().add(
                              QrCodeDetected(barcode.rawValue ?? ""),
                            );
                          }
                        }
                      },
                    ),

                    // Beautiful Overlay
                    _ScannerOverlay(
                      locale: locale,
                      isTorchOn: _controller.torchEnabled,
                      onTorchToggle: () => _controller.toggleTorch(),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildPermissionRequest(S locale) {
    return Container(
      color: AppColors.brightWhite,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: context.adaptiveIcon(80.sp),
                color: AppColors.primary,
              ),
              SizedBox(height: 24.h),
              Text(
                locale.camera_permission_required,
                style: TextStyle(
                  fontSize: context.adaptiveFont(18.sp),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              CustomElevatedButton(
                title: locale.grant_permission,
                onPressed: _requestPermission,
                width: 200.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleScanSuccess(BuildContext context, QrScannerSuccess state) {
    if (_isProcessingResult) return;
    _isProcessingResult = true;

    _controller.stop();

    if (widget.returnCodeOnly) {
      Navigator.of(context).pop(state.code);
      return;
    }

    Navigator.of(context).pop(state.code);
  }
}

class _ScannerOverlay extends StatefulWidget {
  final S locale;
  final bool isTorchOn;
  final VoidCallback onTorchToggle;

  const _ScannerOverlay({
    required this.locale,
    required this.isTorchOn,
    required this.onTorchToggle,
  });

  @override
  State<_ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<_ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanAreaSize = 250.w;

    return Stack(
      children: [
        // Semi-transparent background with a hole in the middle
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: scanAreaSize,
                  height: scanAreaSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scanning Area Borders and Animation
        Center(
          child: Container(
            width: scanAreaSize,
            height: scanAreaSize,
            padding: EdgeInsets.all(2.r),
            child: Stack(
              children: [
                _ScannerCorner(isTop: true, isLeft: true),
                _ScannerCorner(isTop: true, isLeft: false),
                _ScannerCorner(isTop: false, isLeft: true),
                _ScannerCorner(isTop: false, isLeft: false),

                // Animated Scanning Line
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Positioned(
                      top: _animationController.value * (scanAreaSize - 4.h),
                      left: 10.w,
                      right: 10.w,
                      child: Container(
                        height: 3.h,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.8),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.primary,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // UI Instructions and Torch
        Positioned(
          top: 150.h,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                widget.locale.place_qr_code,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.adaptiveFont(16.sp),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 100.h,
          left: 0,
          right: 0,
          child: Column(
            children: [
              GestureDetector(
                onTap: widget.onTorchToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    color: widget.isTorchOn
                        ? AppColors.primary
                        : Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: widget.isTorchOn
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    widget.isTorchOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                    size: context.adaptiveIcon(30.sp),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                widget.isTorchOn ? "Flash ON" : "Flash OFF",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: context.adaptiveFont(12.sp),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScannerCorner extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const _ScannerCorner({required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      child: Container(
        width: 35.w,
        height: 35.w,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
            bottom: isTop
                ? BorderSide.none
                : const BorderSide(color: AppColors.primary, width: 4),
            left: isLeft
                ? const BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
            right: isLeft
                ? BorderSide.none
                : const BorderSide(color: AppColors.primary, width: 4),
          ),
          borderRadius: BorderRadius.only(
            topLeft: isTop && isLeft ? Radius.circular(20.r) : Radius.zero,
            topRight: isTop && !isLeft ? Radius.circular(20.r) : Radius.zero,
            bottomLeft: !isTop && isLeft ? Radius.circular(20.r) : Radius.zero,
            bottomRight: !isTop && !isLeft
                ? Radius.circular(20.r)
                : Radius.zero,
          ),
        ),
      ),
    );
  }
}
