import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../bloc/qr_scanner/qr_scanner_bloc.dart';

/// QR Scanner Screen
/// Beautiful and user-friendly QR code scanner
class QrScannerScreen extends StatefulWidget {
  /// If true, returns the scanned code as string instead of navigating to visit details
  final bool returnCodeOnly;

  const QrScannerScreen({super.key, this.returnCodeOnly = false});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController? _controller;
  bool _hasPermission = false;
  bool _isCheckingPermission = true;
  bool _isProcessingResult = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        final status = await Permission.camera.status;
        if (mounted) {
          if (status.isGranted) {
            setState(() {
              _hasPermission = true;
              _isCheckingPermission = false;
            });
            _initializeScanner();
          } else {
            setState(() {
              _hasPermission = false;
              _isCheckingPermission = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _hasPermission = false;
            _isCheckingPermission = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _hasPermission = true;
          _isCheckingPermission = false;
        });
        _initializeScanner();
      }
    }
  }

  void _initializeScanner() {
    if (mounted) {
      _controller?.dispose();
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
      _controller?.start();
      if (mounted) {
        setState(() {});
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
        _initializeScanner();
      } else if (status.isPermanentlyDenied) {
        if (mounted) {
          UnifiedSnackbar.error(
            context,
            message:
                'Camera permission is permanently denied. Please enable it in settings.',
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final currentLocale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColors.brightWhite,
      appBar: AppBar(
        backgroundColor: AppColors.brightWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          locale.qr_scanner,
          style: TextStyle(
            fontSize: 20.sp,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: _isCheckingPermission
          ? const Center(child: LoadingWidget(withPadding: false))
          : !_hasPermission
          ? _buildPermissionRequest(locale)
          : BlocConsumer<QrScannerBloc, QrScannerState>(
              listener: (context, state) {
                if (state is QrScannerSuccess) {
                  // Handle successful scan
                  _handleScanSuccess(context, state);
                } else if (state is QrScannerError) {
                  // Show error using UnifiedSnackbar
                  if (mounted) {
                    UnifiedSnackbar.error(context, message: state.error);
                    // Reset after showing error
                    final bloc = context.read<QrScannerBloc>();
                    Future.delayed(const Duration(seconds: 2), () {
                      if (!mounted) return;
                      bloc.add(ResetScanner());
                    });
                  }
                }
              },
              builder: (context, state) {
                return _buildScannerContent(locale, currentLocale, state);
              },
            ),
    );
  }

  Widget _buildPermissionRequest(S locale) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80.sp,
              color: AppColors.secondaryText,
            ),
            SizedBox(height: 24.h),
            Text(
              locale.camera_permission_required,
              style: TextStyle(
                fontSize: 16.sp,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _requestPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.brightWhite,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                locale.grant_permission,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerContent(
    S locale,
    String currentLocale,
    QrScannerState state,
  ) {
    return SafeArea(
      child: Column(
        children: [
          // Instructions at top
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: AppColors.darkWhite,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      locale.place_qr_code,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Cairo',
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Large card with camera
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryText.withValues(alpha: 0.05),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Stack(
                    children: [
                      // Camera view
                      _buildScannerView(),
                      // Scanning frame overlay
                      _buildScanningFrame(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom controls
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryText.withValues(alpha: 0.05),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  _controller?.toggleTorch();
                },
                icon: Icon(
                  Icons.flashlight_on,
                  color: AppColors.primaryText,
                  size: 28.sp,
                ),
                padding: EdgeInsets.all(16.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    if (_controller == null) {
      return const Center(child: LoadingWidget(withPadding: false));
    }

    return MobileScanner(
      controller: _controller!,
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        if (barcodes.isNotEmpty) {
          final barcode = barcodes.first;
          if (barcode.rawValue != null) {
            context.read<QrScannerBloc>().add(
              QrCodeDetected(barcode.rawValue!),
            );
          }
        }
      },
    );
  }

  Widget _buildScanningFrame() {
    return Center(
      child: SizedBox(
        width: 280.w,
        height: 280.w,
        child: Stack(
          children: [
            // Top-left corner
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  border: const Border(
                    top: BorderSide(color: AppColors.primary, width: 3),
                    left: BorderSide(color: AppColors.primary, width: 3),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                  ),
                ),
              ),
            ),
            // Top-right corner
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  border: const Border(
                    top: BorderSide(color: AppColors.primary, width: 3),
                    right: BorderSide(color: AppColors.primary, width: 3),
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12.r),
                  ),
                ),
              ),
            ),
            // Bottom-left corner
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  border: const Border(
                    bottom: BorderSide(color: AppColors.primary, width: 3),
                    left: BorderSide(color: AppColors.primary, width: 3),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.r),
                  ),
                ),
              ),
            ),
            // Bottom-right corner
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  border: const Border(
                    bottom: BorderSide(color: AppColors.primary, width: 3),
                    right: BorderSide(color: AppColors.primary, width: 3),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleScanSuccess(BuildContext context, QrScannerSuccess state) {
    // Prevent multiple calls
    if (_isProcessingResult) return;
    _isProcessingResult = true;

    // Stop scanner temporarily
    _controller?.stop();

    // If returnCodeOnly mode, return the code string directly as-is
    if (widget.returnCodeOnly) {
      Navigator.of(context).pop(state.code);
      return;
    }

    // For non-returnCodeOnly mode, try to parse if possible
    // But don't show errors if parsing fails - just return the raw code
    if (state.qrCode != null) {
      // Close scanner first
      Navigator.of(context).pop();
      // TODO: Navigate to visit details when route is implemented
      // final qrCode = state.qrCode!;
      // context.pushNamed(
      //   Routes.visitDetails,
      //   extra: {'visitId': qrCode.visitId, 'visitorId': qrCode.visitorId},
      // );
    } else if (state.parsedData != null) {
      // Fallback for old format
      final visitId = state.parsedData!['visit_id'];
      final visitorId = state.parsedData!['visitor_id'];

      if (visitId != null && visitorId != null) {
        // Close scanner first
        Navigator.of(context).pop();
        // TODO: Navigate to visit details when route is implemented
        // context.pushNamed(
        //   Routes.visitDetails,
        //   extra: {'visitId': visitId, 'visitorId': visitorId},
        // );
      } else {
        // If parsing fails, just return the raw code
        Navigator.of(context).pop(state.code);
      }
    } else {
      // If no parsing data, just return the raw code
      Navigator.of(context).pop(state.code);
    }
  }
}
