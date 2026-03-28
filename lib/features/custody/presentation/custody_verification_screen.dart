import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/responsive_layout.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_elevated_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/repository/auth_local_repository.dart';
import '../bloc/custody_verification/custody_verification_bloc.dart';
import '../bloc/custody_verification/custody_verification_event.dart';
import '../bloc/custody_verification/custody_verification_state.dart';
import 'widgets/verification_code_input.dart';

class CustodyVerificationScreen extends StatefulWidget {
  final int custodyId;

  const CustodyVerificationScreen({super.key, required this.custodyId});

  @override
  State<CustodyVerificationScreen> createState() =>
      _CustodyVerificationScreenState();
}

class _CustodyVerificationScreenState extends State<CustodyVerificationScreen> {
  final _verificationCodeController = TextEditingController();
  final _notesController = TextEditingController();
  String _verificationCode = '';
  bool _isResending = false;

  @override
  void dispose() {
    _verificationCodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleVerify() {
    if (_verificationCode.length != 6) {
      UnifiedSnackbar.error(
        context,
        message: S.of(context).please_enter_verification_code,
      );
      return;
    }

    context.read<CustodyVerificationBloc>().add(
      VerifyCustody(
        custodyId: widget.custodyId,
        verificationCode: _verificationCode,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
  }

  void _handleResend() {
    setState(() {
      _isResending = true;
    });

    context.read<CustodyVerificationBloc>().add(
      ResendVerificationCode(widget.custodyId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: locale.verify_custody,
        showBackButton: true,
        onBackPressed: () {
          // Navigate to main screen instead of pop to avoid empty stack error
          context.pushReplacement(Routes.mainScreenPath);
        },
      ),
      body: BlocConsumer<CustodyVerificationBloc, CustodyVerificationState>(
        listener: (context, state) {
          if (state is CustodyVerificationSuccess) {
            // Clear custody verification state after successful verification
            AuthLocalRepository.clearCustodyVerificationState();

            UnifiedSnackbar.success(
              context,
              message: locale.custody_verified_successfully,
            );
            context.pushReplacement(Routes.mainScreenPath);
          } else if (state is CustodyVerificationResendSuccess) {
            UnifiedSnackbar.success(
              context,
              message: locale.verification_code_resent,
            );
            setState(() {
              _isResending = false;
              _verificationCode = '';
              _verificationCodeController.clear();
            });
          } else if (state is CustodyVerificationError) {
            UnifiedSnackbar.error(context, message: state.message);
            setState(() {
              _isResending = false;
            });
          }
        },
        builder: (context, state) {
          final isVerifying = state is CustodyVerificationVerifying;
          final isResending = state is CustodyVerificationResending;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info card
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: context.adaptiveIcon(24.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          locale.verification_info_message,
                          style: TextStyle(
                            fontSize: context.adaptiveFont(14.sp),
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                // Verification code input
                Text(
                  locale.enter_verification_code,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.adaptiveFont(16.sp),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 24.h),
                VerificationCodeInput(
                  onChanged: (code) {
                    setState(() {
                      _verificationCode = code;
                    });
                  },
                  onCompleted: (code) {
                    _handleVerify();
                  },
                  enabled: !isVerifying && !isResending,
                  errorText: state is CustodyVerificationError
                      ? state.message
                      : null,
                ),
                SizedBox(height: 24.h),

                // Notes field (optional)
                CustomTextField(
                  controller: _notesController,
                  label: locale.notes,
                  hintText: locale.enter_notes_optional,
                  keyboardType: TextInputType.multiline,
                  prefixIcon: Icon(
                    Icons.note_outlined,
                    color: AppColors.secondaryText,
                    size: context.adaptiveIcon(22.sp),
                  ),
                ),
                SizedBox(height: 24.h),

                // Verify button
                CustomElevatedButton(
                  onPressed: (isVerifying || isResending)
                      ? null
                      : _handleVerify,
                  title: locale.verify,
                  isLoading: isVerifying,
                ),
                SizedBox(height: 16.h),

                // Resend code button
                TextButton(
                  onPressed: (isVerifying || isResending || _isResending)
                      ? null
                      : _handleResend,
                  child: Text(
                    locale.resend_code,
                    style: TextStyle(
                      fontSize: context.adaptiveFont(14.sp),
                      fontWeight: FontWeight.w600,
                      color: (isVerifying || isResending || _isResending)
                          ? AppColors.secondaryText
                          : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
