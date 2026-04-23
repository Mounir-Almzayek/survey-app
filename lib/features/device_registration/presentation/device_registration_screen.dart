import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/unified_snackbar.dart';
import '../../../../core/services/device_bound_key_service.dart';
import '../../../../core/services/device_local_metadata_service.dart';
import '../../../core/routes/app_routes.dart';
import '../bloc/device_info/device_info_bloc.dart';
import '../bloc/device_info/device_info_state.dart';
import '../bloc/validate_token/validate_token_bloc.dart';
import '../bloc/validate_token/validate_token_event.dart';
import '../bloc/validate_token/validate_token_state.dart';
import '../bloc/complete_registration/complete_registration_bloc.dart';
import '../bloc/complete_registration/complete_registration_state.dart';
import '../bloc/verify_key/verify_key_bloc.dart';
import '../bloc/verify_key/verify_key_event.dart';
import '../models/registration_method.dart';
import 'widgets/device_info_section.dart';
import 'widgets/device_registration_header.dart';
import 'widgets/registration_method_indicator.dart';
import 'widgets/registration_action_section.dart';

class DeviceRegistrationScreen extends StatefulWidget {
  final String token;
  final bool fromDeepLink;

  const DeviceRegistrationScreen({
    super.key,
    required this.token,
    this.fromDeepLink = false,
  });

  @override
  State<DeviceRegistrationScreen> createState() =>
      _DeviceRegistrationScreenState();
}

class _DeviceRegistrationScreenState extends State<DeviceRegistrationScreen> {
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
    for (final method in _registrationMethodPriority) {
      if (_isMethodAvailable(method)) return method;
    }
    return RegistrationMethod.cookieBased;
  }

  bool _isMethodAvailable(RegistrationMethod method) {
    switch (method) {
      case RegistrationMethod.deviceBoundKey:
        return true;
      case RegistrationMethod.cookieBased:
        return true;
    }
  }

  Future<void> _checkDeviceKey(BuildContext context) async {
    try {
      final deviceBoundKeyService = DeviceBoundKeyService();
      final keyId = await deviceBoundKeyService.getKeyId();
      if (keyId != null && keyId.isNotEmpty) {
        _verifyKeyBloc.add(VerifyKey(keyId: keyId));
      }
    } catch (e) {
      if (kDebugMode) print('DeviceRegistrationScreen Error: $e');
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
                DeviceLocalMetadataService().savePhysicalDeviceId(
                  state.response.physicalDeviceId,
                );
                final method = _getRegistrationMethod();
                if (method == RegistrationMethod.deviceBoundKey) {
                  _checkDeviceKey(context);
                }
              } else if (state is ValidateTokenFailure) {
                UnifiedSnackbar.error(context, message: state.message);
                Future.delayed(const Duration(seconds: 2), () {
                  if (context.mounted) context.pop();
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
                      state.response.message ??
                      locale.device_registered_success,
                );
                Future.delayed(const Duration(seconds: 2), () {
                  if (context.mounted)
                    context.pushReplacement(Routes.loginPath);
                });
              } else if (state is CompleteRegistrationFailure) {
                UnifiedSnackbar.error(context, message: state.message);
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: AppColors.brightWhite,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
              onPressed: () => context.pop(),
            ),
          ),
          body: Stack(
            children: [
              _buildBackground(),
              SafeArea(
                child: BlocBuilder<DeviceInfoBloc, DeviceInfoState>(
                  builder: (context, deviceInfoState) {
                    if (deviceInfoState is DeviceInfoLoading) {
                      return const Center(child: LoadingWidget());
                    }

                    if (deviceInfoState is DeviceInfoLoaded) {
                      return BlocBuilder<ValidateTokenBloc, ValidateTokenState>(
                        builder: (context, tokenState) {
                          if (tokenState is ValidateTokenLoading) {
                            return const Center(child: LoadingWidget());
                          }

                          if (tokenState is ValidateTokenSuccess) {
                            return _buildContent(
                              context,
                              deviceInfoState.fingerprint,
                              tokenState,
                            );
                          }

                          return _buildErrorState(
                            tokenState is ValidateTokenFailure
                                ? tokenState.message
                                : "Unknown error",
                          );
                        },
                      );
                    }

                    return _buildErrorState(
                      deviceInfoState is DeviceInfoError
                          ? deviceInfoState.message
                          : "Unknown error",
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100.h,
          right: -50.w,
          child: _buildBlob(300.w, AppColors.primary.withOpacity(0.05)),
        ),
        Positioned(
          bottom: 100.h,
          left: -100.w,
          child: _buildBlob(400.w, AppColors.accent.withOpacity(0.05)),
        ),
      ],
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: context.adaptiveIcon(64.sp),
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              message,
              style: TextStyle(
                color: AppColors.error,
                fontSize: context.adaptiveFont(16.sp),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    fingerprint,
    ValidateTokenSuccess tokenState,
  ) {
    final tokenResponse = tokenState.response;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
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
          RegistrationMethodIndicator(method: _getRegistrationMethod()),
          SizedBox(height: 40.h),
          RegistrationActionSection(
            token: widget.token,
            fingerprint: tokenState.fingerprint,
            method: _getRegistrationMethod(),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}
