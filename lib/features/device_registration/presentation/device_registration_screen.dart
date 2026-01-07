import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/unified_snackbar.dart';
import '../../../../core/services/device_storage_service.dart';
import '../bloc/device_info/device_info_bloc.dart';
import '../bloc/device_info/device_info_state.dart';
import '../bloc/validate_token/validate_token_bloc.dart';
import '../bloc/validate_token/validate_token_event.dart';
import '../bloc/validate_token/validate_token_state.dart';
import '../bloc/complete_registration/complete_registration_bloc.dart';
import '../bloc/complete_registration/complete_registration_event.dart';
import '../bloc/complete_registration/complete_registration_state.dart';
import '../models/registration_method.dart';
import 'widgets/device_info_section.dart';
import 'widgets/device_registration_header.dart';
import 'widgets/registration_method_indicator.dart';

class DeviceRegistrationScreen extends StatefulWidget {
  final String token;

  const DeviceRegistrationScreen({super.key, required this.token});

  @override
  State<DeviceRegistrationScreen> createState() =>
      _DeviceRegistrationScreenState();
}

class _DeviceRegistrationScreenState extends State<DeviceRegistrationScreen> {
  /// Priority list for registration methods.
  ///
  /// Order matters: the first "available" method will be used.
  /// Currently:
  /// - Device-Bound Key is the primary method.
  /// - Cookie-based is a safe fallback.
  static const List<RegistrationMethod> _registrationMethodPriority = [
    RegistrationMethod.deviceBoundKey,
    RegistrationMethod.cookieBased,
  ];

  @override
  void initState() {
    super.initState();
    _startValidation();
  }

  void _startValidation() {
    // Wait for device info to load first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deviceInfoState = context.read<DeviceInfoBloc>().state;
      if (deviceInfoState is DeviceInfoLoaded) {
        context.read<ValidateTokenBloc>().add(
          ValidateToken(
            token: widget.token,
            fingerprint: deviceInfoState.fingerprint,
          ),
        );
      }
    });
  }

  /// Returns the best registration method based on the configured priority
  /// and current runtime availability of each method.
  RegistrationMethod _getRegistrationMethod() {
    for (final method in _registrationMethodPriority) {
      if (_isMethodAvailable(method)) {
        return method;
      }
    }

    // Absolute fallback – should normally never be hit.
    return RegistrationMethod.cookieBased;
  }

  /// Encapsulates the logic that decides if a method is available
  /// on the current device / build.
  bool _isMethodAvailable(RegistrationMethod method) {
    switch (method) {
      case RegistrationMethod.deviceBoundKey:
        // For now, we consider device-bound key always available on supported
        // platforms. If you need to check hardware / biometrics later,
        // add that logic here.
        return true;
      case RegistrationMethod.cookieBased:
        // Always available as a fallback.
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<DeviceInfoBloc, DeviceInfoState>(
          listener: (context, state) {
            if (state is DeviceInfoLoaded) {
              // Start token validation when device info is loaded
              context.read<ValidateTokenBloc>().add(
                ValidateToken(
                  token: widget.token,
                  fingerprint: state.fingerprint,
                ),
              );
            } else if (state is DeviceInfoError) {
              UnifiedSnackbar.error(context, message: state.message);
            }
          },
        ),
        BlocListener<ValidateTokenBloc, ValidateTokenState>(
          listener: (context, state) {
            if (state is ValidateTokenSuccess) {
              // Save device ID for location tracking
              DeviceStorageService.saveDeviceId(
                state.response.physicalDeviceId,
              );
            } else if (state is ValidateTokenFailure) {
              UnifiedSnackbar.error(context, message: state.message);
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) {
                  context.pop();
                }
              });
            }
          },
        ),
        BlocListener<CompleteRegistrationBloc, CompleteRegistrationState>(
          listener: (context, state) {
            if (state is CompleteRegistrationSuccess) {
              UnifiedSnackbar.success(
                context,
                message:
                    state.response.message ?? 'Device registered successfully',
              );
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) {
                  context.pop();
                }
              });
            } else if (state is CompleteRegistrationFailure) {
              UnifiedSnackbar.error(context, message: state.message);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
            onPressed: () => context.pop(),
          ),
          title: Text(
            locale.register_device,
            style: GoogleFonts.cairo(
              color: AppColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocBuilder<DeviceInfoBloc, DeviceInfoState>(
          builder: (context, deviceInfoState) {
            if (deviceInfoState is DeviceInfoLoading) {
              return const LoadingWidget();
            }

            if (deviceInfoState is DeviceInfoError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        deviceInfoState.message,
                        style: GoogleFonts.cairo(
                          color: AppColors.error,
                          fontSize: 16.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (deviceInfoState is DeviceInfoLoaded) {
              return BlocBuilder<ValidateTokenBloc, ValidateTokenState>(
                builder: (context, tokenState) {
                  if (tokenState is ValidateTokenLoading) {
                    return const LoadingWidget();
                  }

                  if (tokenState is ValidateTokenFailure) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64.sp,
                              color: AppColors.error,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              tokenState.message,
                              style: GoogleFonts.cairo(
                                color: AppColors.error,
                                fontSize: 16.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (tokenState is ValidateTokenSuccess) {
                    return _buildContent(
                      context,
                      deviceInfoState.fingerprint,
                      tokenState,
                    );
                  }

                  return const SizedBox.shrink();
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    deviceInfoStateFingerprint,
    ValidateTokenSuccess tokenState,
  ) {
    final locale = S.of(context);
    final tokenResponse = tokenState.response;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DeviceRegistrationHeader(
            deviceName: tokenResponse.physicalDevice.name,
            deviceType: tokenResponse.physicalDevice.type,
            zoneId: tokenResponse.physicalDevice.zoneId,
          ),
          SizedBox(height: 24.h),
          DeviceInfoSection(fingerprint: tokenState.fingerprint),
          SizedBox(height: 24.h),
          // Show registration method indicator
          RegistrationMethodIndicator(method: _getRegistrationMethod()),
          SizedBox(height: 32.h),
          BlocBuilder<CompleteRegistrationBloc, CompleteRegistrationState>(
            builder: (context, registrationState) {
              final isLoading =
                  registrationState is CompleteRegistrationLoading;

              final method = _getRegistrationMethod();
              final buttonText = locale.link_device;

              return CustomElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        context.read<CompleteRegistrationBloc>().add(
                          CompleteRegistration(
                            token: widget.token,
                            fingerprint: tokenState.fingerprint,
                            method: method,
                          ),
                        );
                      },
                title: buttonText,
                isLoading: isLoading,
                width: double.infinity,
              );
            },
          ),
        ],
      ),
    );
  }
}
