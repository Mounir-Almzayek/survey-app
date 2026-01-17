import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/custom_elevated_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../bloc/email_verification/email_verification_bloc.dart';
import '../widgets/auth_scaffold.dart';
import '../../../core/utils/responsive_layout.dart';

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

    return BlocConsumer<EmailVerificationBloc, EmailVerificationState>(
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
        return AuthScaffold(
          showBackButton: true,
          title: locale.activate_account,
          subtitle: locale.enter_verification_code_instruction,
          child: Form(
            key: formKey,
            child: Column(
              children: [
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
                      context.read<EmailVerificationBloc>().add(UpdateEmail(v)),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? locale.no_user_name : null,
                ),
                SizedBox(height: context.responsive(20.h, tablet: 24.h)),
                CustomTextField(
                  label: locale.code,
                  hintText: "123456",
                  controller: codeController,
                  prefixIcon: Icon(
                    Icons.pin_rounded,
                    color: const Color(0xFF90A1B9),
                    size: context.adaptiveIcon(22.sp),
                  ),
                  onChanged: (v) =>
                      context.read<EmailVerificationBloc>().add(UpdateCode(v)),
                  validator: (v) => (v == null || v.isEmpty)
                      ? locale.please_enter_verification_code
                      : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      if (emailController.text.isNotEmpty) {
                        context.read<EmailVerificationBloc>().add(ResendCode());
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
                        fontSize: context.adaptiveFont(12.sp),
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.responsive(24.h, tablet: 32.h)),
                CustomElevatedButton(
                  title: locale.verify,
                  isLoading: state is EmailVerificationLoading,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<EmailVerificationBloc>().add(VerifyEmail());
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
