import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

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
import '../bloc/verify_key/verify_key_bloc.dart';
import '../bloc/verify_key/verify_key_event.dart';
import '../bloc/verify_key/verify_key_state.dart';
import '../../../../core/services/device_bound_key_service.dart';
import '../../../../core/services/device_local_metadata_service.dart';
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

  late final VerifyKeyBloc _verifyKeyBloc;

  @override
  void initState() {
    super.initState();
    _verifyKeyBloc = VerifyKeyBloc();
    _startValidation();
  }

  @override
  void dispose() {
    _verifyKeyBloc.close();
    super.dispose();
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

  /// Check if device has a key registered locally and verify it with backend
  Future<void> _checkDeviceKey(BuildContext context) async {
    try {
      final deviceBoundKeyService = DeviceBoundKeyService();
      final keyId = await deviceBoundKeyService.getKeyId();

      if (keyId != null && keyId.isNotEmpty) {
        // Trigger verification
        _verifyKeyBloc.add(VerifyKey(keyId: keyId));
      } else {
        // No keyId found locally, allow registration
        if (kDebugMode) {
          print(
            'DeviceRegistrationScreen: No keyId found locally, allowing registration',
          );
        }
      }
    } catch (e) {
      // If error occurs, allow registration (fail open)
      if (kDebugMode) {
        print('DeviceRegistrationScreen: Error checking device key: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return BlocProvider.value(
      value: _verifyKeyBloc,
      child: MultiBlocListener(
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
                DeviceLocalMetadataService().savePhysicalDeviceId(
                  state.response.physicalDeviceId,
                );

                // Check if device has a key registered locally
                // Only verify for device-bound-key method
                final method = _getRegistrationMethod();
                if (kDebugMode) {
                  print(
                    'DeviceRegistrationScreen: Registration method: $method',
                  );
                }
                if (method == RegistrationMethod.deviceBoundKey) {
                  if (kDebugMode) {
                    print('DeviceRegistrationScreen: Checking device key...');
                  }
                  _checkDeviceKey(context);
                } else {
                  if (kDebugMode) {
                    print(
                      'DeviceRegistrationScreen: Skipping key verification (method: $method)',
                    );
                  }
                }
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
          BlocListener<VerifyKeyBloc, VerifyKeyState>(
            listener: (context, state) {
              if (state is VerifyKeyFailure) {
                // If verification fails, allow registration (key not found or expired)
                // No need to show error message
              }
            },
          ),
          BlocListener<CompleteRegistrationBloc, CompleteRegistrationState>(
            listener: (context, state) {
              if (state is CompleteRegistrationSuccess) {
                UnifiedSnackbar.success(
                  context,
                  message:
                      state.response.message ??
                      'Device registered successfully',
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
              style: TextStyle(
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
                          style: TextStyle(
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
                                style: TextStyle(
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
          BlocBuilder<VerifyKeyBloc, VerifyKeyState>(
            builder: (context, verifyKeyState) {
              return BlocBuilder<
                CompleteRegistrationBloc,
                CompleteRegistrationState
              >(
                builder: (context, registrationState) {
                  final isLoading =
                      registrationState is CompleteRegistrationLoading;

                  final isVerifyingKey = verifyKeyState is VerifyKeyLoading;
                  final isKeyAlreadyRegistered =
                      verifyKeyState is VerifyKeySuccess &&
                      verifyKeyState.response.valid;

                  final method = _getRegistrationMethod();
                  final buttonText = locale.link_device;

                  // Show error message if key is already registered
                  if (isKeyAlreadyRegistered) {
                    return Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 24.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  locale.device_already_registered,
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        CustomElevatedButton(
                          onPressed: null, // Disable button
                          title: buttonText,
                          isLoading: false,
                          width: double.infinity,
                        ),
                      ],
                    );
                  }

                  return CustomElevatedButton(
                    onPressed: (isLoading || isVerifyingKey)
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
                    title: isVerifyingKey
                        ? locale.verifying_device_key
                        : buttonText,
                    isLoading: isLoading || isVerifyingKey,
                    width: double.infinity,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
