import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/models/fingerprint.dart';
import '../../bloc/complete_registration/complete_registration_bloc.dart';
import '../../bloc/complete_registration/complete_registration_event.dart';
import '../../bloc/complete_registration/complete_registration_state.dart';
import '../../bloc/verify_key/verify_key_bloc.dart';
import '../../bloc/verify_key/verify_key_state.dart';
import '../../models/registration_method.dart';

class RegistrationActionSection extends StatelessWidget {
  final String token;
  final Fingerprint fingerprint;
  final RegistrationMethod method;

  const RegistrationActionSection({
    super.key,
    required this.token,
    required this.fingerprint,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return BlocBuilder<VerifyKeyBloc, VerifyKeyState>(
      builder: (context, verifyKeyState) {
        return BlocBuilder<CompleteRegistrationBloc, CompleteRegistrationState>(
          builder: (context, registrationState) {
            final isLoading = registrationState is CompleteRegistrationLoading;
            final isVerifyingKey = verifyKeyState is VerifyKeyLoading;
            final isKeyAlreadyRegistered =
                verifyKeyState is VerifyKeySuccess &&
                verifyKeyState.response.valid;

            if (isKeyAlreadyRegistered) {
              return _buildAlreadyRegisteredCard(locale);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomElevatedButton(
                  onPressed: (isLoading || isVerifyingKey)
                      ? null
                      : () {
                          context.read<CompleteRegistrationBloc>().add(
                            CompleteRegistration(
                              token: token,
                              fingerprint: fingerprint,
                              method: method,
                            ),
                          );
                        },
                  title: isVerifyingKey
                      ? locale.verifying_device_key
                      : locale.link_device,
                  isLoading: isLoading || isVerifyingKey,
                  width: double.infinity,
                ),
                SizedBox(height: 12.h),
                Text(
                  locale.complete_registration_tap_notice,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAlreadyRegisteredCard(S locale) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.error.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 32.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            locale.device_already_registered,
            style: TextStyle(
              color: AppColors.error,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            locale.device_already_registered_desc,
            style: TextStyle(color: AppColors.secondaryText, fontSize: 13.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
