import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/widgets/custom_elevated_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../bloc/forgot_password/forgot_password_bloc.dart';
import '../widgets/auth_scaffold.dart';
import '../../../core/utils/responsive_layout.dart';

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

    return BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
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
        return AuthScaffold(
          showBackButton: true,
          title: state.step == ForgotPasswordStep.email
              ? locale.reset_password
              : locale.enter_code,
          subtitle: state.step == ForgotPasswordStep.email
              ? locale.enter_email_reset
              : locale.enter_code_sent(state.email),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                if (state.step == ForgotPasswordStep.email) ...[
                  CustomTextField(
                    label: locale.email,
                    hintText: "researcher@example.com",
                    controller: emailController,
                    prefixIcon: Icon(
                      Icons.mail_outline_rounded,
                      color: const Color(0xFF90A1B9),
                      size: context.adaptiveIcon(22.sp),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) =>
                        context.read<ForgotPasswordBloc>().add(UpdateEmail(v)),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? locale.no_user_name : null,
                  ),
                ] else ...[
                  CustomTextField(
                    label: locale.verification_code,
                    hintText: "123456",
                    controller: codeController,
                    prefixIcon: Icon(
                      Icons.pin_rounded,
                      color: const Color(0xFF90A1B9),
                      size: context.adaptiveIcon(22.sp),
                    ),
                    onChanged: (v) =>
                        context.read<ForgotPasswordBloc>().add(UpdateCode(v)),
                    validator: (v) => (v == null || v.isEmpty)
                        ? locale.please_enter_code
                        : null,
                  ),
                  SizedBox(height: context.responsive(20.h, tablet: 24.h)),
                  CustomTextField(
                    label: locale.new_password,
                    hintText: "********",
                    controller: passwordController,
                    isPassword: true,
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: const Color(0xFF90A1B9),
                      size: context.adaptiveIcon(22.sp),
                    ),
                    onChanged: (v) => context.read<ForgotPasswordBloc>().add(
                      UpdateNewPassword(v),
                    ),
                    validator: (v) => (v == null || v.length < 8)
                        ? locale.password_too_short
                        : null,
                  ),
                ],
                SizedBox(height: context.responsive(32.h, tablet: 40.h)),
                CustomElevatedButton(
                  title: state.step == ForgotPasswordStep.email
                      ? locale.send_code
                      : locale.reset_password,
                  isLoading: state is ForgotPasswordLoading,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (state.step == ForgotPasswordStep.email) {
                        context.read<ForgotPasswordBloc>().add(
                          RequestResetCode(),
                        );
                      } else {
                        context.read<ForgotPasswordBloc>().add(ResetPassword());
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
