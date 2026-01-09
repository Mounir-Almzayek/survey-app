import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/assets.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/custom_elevated_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../bloc/email_verification/email_verification_bloc.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Colors.white, Color(0xFFF0FDFA)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: -100.h,
              left: -100.w,
              child: _buildBlob(300.w, AppColors.primaryEnd.withOpacity(0.03)),
            ),

            SafeArea(
              child: BlocConsumer<EmailVerificationBloc, EmailVerificationState>(
                listener: (context, state) {
                  if (state is EmailVerificationFailure) {
                    UnifiedSnackbar.error(context, message: state.error);
                  } else if (state is EmailVerificationSuccess) {
                    UnifiedSnackbar.success(
                      context,
                      message: locale.email_verified_success,
                    );
                    context.pop();
                  } else if (state is CodeResendSuccess) {
                    UnifiedSnackbar.success(
                      context,
                      message: locale.verification_code_resent,
                    );
                  }
                },
                builder: (context, state) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          Hero(
                            tag: 'app_logo',
                            child: Image.asset(
                              Assets.logo1,
                              width: 80.w,
                              height: 80.h,
                            ),
                          ),
                          SizedBox(height: 32.h),
                          Text(
                            locale.activate_account,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            locale.enter_verification_code_instruction,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          SizedBox(height: 40.h),

                          Container(
                            padding: EdgeInsets.all(24.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              border: Border.all(
                                color: AppColors.border.withOpacity(0.5),
                              ),
                            ),
                            child: Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  CustomTextField(
                                    label: locale.email,
                                    hintText: "researcher@example.com",
                                    controller: emailController,
                                    prefixIcon: const Icon(
                                      Icons.mail_outline_rounded,
                                      color: Color(0xFF90A1B9),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (v) => context
                                        .read<EmailVerificationBloc>()
                                        .add(UpdateEmail(v)),
                                    validator: (v) => (v == null || v.isEmpty)
                                        ? locale.no_user_name
                                        : null,
                                  ),
                                  SizedBox(height: 20.h),
                                  CustomTextField(
                                    label: locale.code,
                                    hintText: "123456",
                                    controller: codeController,
                                    prefixIcon: const Icon(
                                      Icons.pin_rounded,
                                      color: Color(0xFF90A1B9),
                                    ),
                                    onChanged: (v) => context
                                        .read<EmailVerificationBloc>()
                                        .add(UpdateCode(v)),
                                    validator: (v) => (v == null || v.isEmpty)
                                        ? locale.please_enter_verification_code
                                        : null,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        if (emailController.text.isNotEmpty) {
                                          context
                                              .read<EmailVerificationBloc>()
                                              .add(ResendCode());
                                        } else {
                                          UnifiedSnackbar.error(
                                            context,
                                            message: locale.no_user_name,
                                          );
                                        }
                                      },
                                      child: Text(
                                        locale.resend_code,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                  CustomElevatedButton(
                                    title: locale.verify,
                                    isLoading:
                                        state is EmailVerificationLoading,
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        context
                                            .read<EmailVerificationBloc>()
                                            .add(VerifyEmail());
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
