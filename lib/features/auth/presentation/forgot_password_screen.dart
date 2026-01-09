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
import '../bloc/forgot_password/forgot_password_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    passwordController.dispose();
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
            // Decorative Blobs
            Positioned(
              top: -100.h,
              right: -100.w,
              child: _buildBlob(
                300.w,
                AppColors.primaryStart.withOpacity(0.03),
              ),
            ),

            SafeArea(
              child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
                listener: (context, state) {
                  if (state is ForgotPasswordFailure) {
                    UnifiedSnackbar.error(context, message: state.error);
                  } else if (state is ForgotPasswordSuccess) {
                    UnifiedSnackbar.success(
                      context,
                      message: locale.password_reset_success,
                    );
                    context.pop();
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
                            state.step == ForgotPasswordStep.email
                                ? locale.reset_password
                                : locale.enter_code,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            state.step == ForgotPasswordStep.email
                                ? locale.enter_email_reset
                                : locale.enter_code_sent(state.email),
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
                                  if (state.step ==
                                      ForgotPasswordStep.email) ...[
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
                                          .read<ForgotPasswordBloc>()
                                          .add(UpdateEmail(v)),
                                      validator: (v) => (v == null || v.isEmpty)
                                          ? locale.no_user_name
                                          : null,
                                    ),
                                  ] else ...[
                                    CustomTextField(
                                      label: locale.verification_code,
                                      hintText: "123456",
                                      controller: codeController,
                                      prefixIcon: const Icon(
                                        Icons.pin_rounded,
                                        color: Color(0xFF90A1B9),
                                      ),
                                      onChanged: (v) => context
                                          .read<ForgotPasswordBloc>()
                                          .add(UpdateCode(v)),
                                      validator: (v) => (v == null || v.isEmpty)
                                          ? locale.please_enter_code
                                          : null,
                                    ),
                                    SizedBox(height: 20.h),
                                    CustomTextField(
                                      label: locale.new_password,
                                      hintText: "********",
                                      controller: passwordController,
                                      isPassword: true,
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                        color: Color(0xFF90A1B9),
                                      ),
                                      onChanged: (v) => context
                                          .read<ForgotPasswordBloc>()
                                          .add(UpdateNewPassword(v)),
                                      validator: (v) =>
                                          (v == null || v.length < 8)
                                          ? locale.password_too_short
                                          : null,
                                    ),
                                  ],
                                  SizedBox(height: 32.h),
                                  CustomElevatedButton(
                                    title:
                                        state.step == ForgotPasswordStep.email
                                        ? locale.send_code
                                        : locale.reset_password,
                                    isLoading: state is ForgotPasswordLoading,
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        if (state.step ==
                                            ForgotPasswordStep.email) {
                                          context
                                              .read<ForgotPasswordBloc>()
                                              .add(RequestResetCode());
                                        } else {
                                          context
                                              .read<ForgotPasswordBloc>()
                                              .add(ResetPassword());
                                        }
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
