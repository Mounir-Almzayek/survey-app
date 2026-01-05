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
import '../../../../core/services/passkey_service.dart';

class DeviceRegistrationScreen extends StatefulWidget {
  final String token;

  const DeviceRegistrationScreen({super.key, required this.token});

  @override
  State<DeviceRegistrationScreen> createState() =>
      _DeviceRegistrationScreenState();
}

class _DeviceRegistrationScreenState extends State<DeviceRegistrationScreen> {
  bool? _passkeySupported;
  bool? _deviceBoundKeySupported;
  bool _isCheckingSupport = true;

  @override
  void initState() {
    super.initState();
    _checkSupport();
    _startValidation();
  }

  Future<void> _checkSupport() async {
    try {
      // Check Passkey support
      final passkeySupported = await PasskeyService.isSupportedStatic();

      if (mounted) {
        setState(() {
          _passkeySupported = passkeySupported;
          _deviceBoundKeySupported =
              true; // Always supported, but prefer Passkey if available
          _isCheckingSupport = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _passkeySupported = false;
          _deviceBoundKeySupported = true; // Fallback to Device-Bound Key
          _isCheckingSupport = false;
        });
      }
    }
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

  RegistrationMethod _getRegistrationMethod() {
    // Priority: Passkey > Device-Bound Key > Cookie-based
    return RegistrationMethod.deviceBoundKey;
    if (_passkeySupported == true) {
      return RegistrationMethod.webauthn;
    } else if (_deviceBoundKeySupported == true) {
      return RegistrationMethod.deviceBoundKey;
    }
    return RegistrationMethod.cookieBased;
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
            if (state is ValidateTokenFailure) {
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
              // Show loading while checking support
              if (_isCheckingSupport) {
                return const LoadingWidget();
              }

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
          _buildRegistrationMethodIndicator(context),
          SizedBox(height: 32.h),
          BlocBuilder<CompleteRegistrationBloc, CompleteRegistrationState>(
            builder: (context, registrationState) {
              final isLoading =
                  registrationState is CompleteRegistrationLoading;

              final method = _getRegistrationMethod();
              String buttonText;
              if (method == RegistrationMethod.webauthn) {
                buttonText = locale.link_device;
              } else {
                buttonText = locale.link_device;
              }

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

  Widget _buildRegistrationMethodIndicator(BuildContext context) {
    final method = _getRegistrationMethod();

    // Determine colors and icons based on method
    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    IconData icon;
    String title;
    String description;

    switch (method) {
      case RegistrationMethod.webauthn:
        backgroundColor = AppColors.primary.withValues(alpha: 0.1);
        borderColor = AppColors.primary.withValues(alpha: 0.3);
        iconColor = AppColors.primary;
        icon = Icons.security_rounded;
        title = 'Secure Registration (Passkey)';
        description = 'Using Face ID / Touch ID for enhanced security';
        break;
      case RegistrationMethod.deviceBoundKey:
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        borderColor = Colors.blue.withValues(alpha: 0.3);
        iconColor = Colors.blue;
        icon = Icons.vpn_key_rounded;
        title = 'Device-Bound Key Registration';
        description = 'Using device-specific key (no cloud sync)';
        break;
      case RegistrationMethod.cookieBased:
        backgroundColor = AppColors.brightWhite;
        borderColor = AppColors.border.withValues(alpha: 0.3);
        iconColor = AppColors.secondaryText;
        icon = Icons.fingerprint_rounded;
        title = 'Standard Registration (Cookie-based)';
        description = 'Using device fingerprint for authentication';
        break;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
