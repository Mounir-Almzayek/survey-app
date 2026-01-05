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
  bool _isCheckingPasskey = true;

  @override
  void initState() {
    super.initState();
    _checkPasskeySupport();
    _startValidation();
  }

  Future<void> _checkPasskeySupport() async {
    try {
      final supported = await PasskeyService.isSupportedStatic();
      if (mounted) {
        setState(() {
          _passkeySupported = supported;
          _isCheckingPasskey = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _passkeySupported = false;
          _isCheckingPasskey = false;
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
    if (_passkeySupported == true) {
      return RegistrationMethod.webauthn;
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
              // Show loading while checking Passkey support
              if (_isCheckingPasskey) {
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

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: method == RegistrationMethod.webauthn
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.brightWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: method == RegistrationMethod.webauthn
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            method == RegistrationMethod.webauthn
                ? Icons.security_rounded
                : Icons.fingerprint_rounded,
            color: method == RegistrationMethod.webauthn
                ? AppColors.primary
                : AppColors.secondaryText,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method == RegistrationMethod.webauthn
                      ? 'Secure Registration (Passkey)'
                      : 'Standard Registration (Cookie-based)',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  method == RegistrationMethod.webauthn
                      ? 'Using Face ID / Touch ID for enhanced security'
                      : 'Using device fingerprint for authentication',
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
