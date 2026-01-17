import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/custom_elevated_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../bloc/login/login_bloc.dart';
import '../widgets/qr_scanner_button.dart';
import '../widgets/auth_scaffold.dart';
import '../../../core/utils/responsive_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return AuthScaffold(
      title: locale.researcher_login,
      subtitle: locale.enter_details,
      topTrailing: const QRScannerButton(),
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
              onChanged: (value) {
                context.read<LoginBloc>().add(UpdateEmail(value));
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return locale.no_user_name;
                }
                return null;
              },
            ),
            SizedBox(height: context.responsive(20.h, tablet: 24.h)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomTextField(
                  label: locale.password,
                  hintText: "********",
                  controller: passwordController,
                  isPassword: true,
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: const Color(0xFF90A1B9),
                    size: context.adaptiveIcon(22.sp),
                  ),
                  onChanged: (value) {
                    context.read<LoginBloc>().add(UpdatePassword(value));
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return locale.no_password;
                    }
                    return null;
                  },
                ),
                TextButton(
                  onPressed: () => context.push(Routes.forgotPasswordPath),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    locale.forgot_password,
                    style: TextStyle(
                      fontSize: context.adaptiveFont(12.sp),
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.responsive(24.h, tablet: 32.h)),

            // 🔹 Login Button
            BlocConsumer<LoginBloc, LoginState>(
              listener: (context, state) {
                if (state is LoginSuccess) {
                  UnifiedSnackbar.success(
                    context,
                    message: locale.login_success,
                  );
                  context.pushReplacement(Routes.mainScreenPath);
                } else if (state is LoginInitiateSuccess) {
                  context.read<LoginBloc>().add(SendVerifyLogin());
                } else if (state is LoginFailure) {
                  UnifiedSnackbar.error(context, message: state.error);
                }
              },
              builder: (context, state) {
                return CustomElevatedButton(
                  title: locale.login,
                  isLoading: state is LoginLoading,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<LoginBloc>().add(SendInitiateLogin());
                    }
                  },
                );
              },
            ),

            SizedBox(height: context.responsive(24.h, tablet: 32.h)),

            // 🔹 Activate Account Link
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  locale.no_active_account,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.adaptiveFont(13.sp),
                    color: AppColors.secondaryText,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(Routes.verifyEmailPath),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    locale.activate,
                    style: TextStyle(
                      fontSize: context.adaptiveFont(13.sp),
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
