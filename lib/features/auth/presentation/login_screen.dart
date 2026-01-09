import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';
import '../../../core/assets/assets.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/custom_elevated_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../bloc/login/login_bloc.dart';
import '../widgets/qr_scanner_button.dart';

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

    return Scaffold(
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
            // 🔹 Decorative Blobs (Inspired by Web)
            Positioned(
              top: -100.h,
              right: -100.w,
              child: _buildBlob(
                400.w,
                AppColors.primaryStart.withOpacity(0.05),
              ),
            ),
            Positioned(
              bottom: -50.h,
              left: -50.w,
              child: _buildBlob(300.w, AppColors.primaryEnd.withOpacity(0.05)),
            ),

            // 🔹 Content
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWide ? 100.w : 24.w,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 🔹 QR Scanner Button (Top Right)
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 16.h),
                                  child: const QRScannerButton(),
                                ),
                              ),

                              const Spacer(flex: 1),

                              // 🔹 Logo Section
                              Hero(
                                tag: 'app_logo',
                                child: Image.asset(
                                  Assets.logo1,
                                  width: isWide ? 120.w : 100.w,
                                  height: isWide ? 120.h : 100.h,
                                ),
                              ),
                              SizedBox(height: 32.h),

                              // 🔹 Form Title
                              Text(
                                locale.researcher_login,
                                style: TextStyle(
                                  fontSize: isWide ? 28.sp : 24.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                locale.enter_details,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isWide ? 16.sp : 14.sp,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              SizedBox(height: 40.h),

                              // 🔹 Login Card
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 500.w),
                                child: Container(
                                  padding: EdgeInsets.all(32.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(32.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 32,
                                        offset: const Offset(0, 16),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: AppColors.border.withOpacity(0.3),
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
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          onChanged: (value) {
                                            context.read<LoginBloc>().add(
                                              UpdateEmail(value),
                                            );
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return locale.no_user_name;
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 20.h),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            CustomTextField(
                                              label: locale.password,
                                              hintText: "********",
                                              controller: passwordController,
                                              isPassword: true,
                                              prefixIcon: const Icon(
                                                Icons.lock_outline_rounded,
                                                color: Color(0xFF90A1B9),
                                              ),
                                              onChanged: (value) {
                                                context.read<LoginBloc>().add(
                                                  UpdatePassword(value),
                                                );
                                              },
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return locale.no_password;
                                                }
                                                return null;
                                              },
                                            ),
                                            TextButton(
                                              onPressed: () => context.push(
                                                Routes.forgotPasswordPath,
                                              ),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: const Size(0, 30),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: Text(
                                                locale.forgot_password,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 24.h),

                                        // 🔹 Login Button
                                        BlocConsumer<LoginBloc, LoginState>(
                                          listener: (context, state) {
                                            if (state is LoginSuccess) {
                                              UnifiedSnackbar.success(
                                                context,
                                                message: locale.login_success,
                                              );
                                              context.pushReplacement(
                                                Routes.mainScreenPath,
                                              );
                                            } else if (state
                                                is LoginInitiateSuccess) {
                                              context.read<LoginBloc>().add(
                                                SendVerifyLogin(),
                                              );
                                            } else if (state is LoginFailure) {
                                              UnifiedSnackbar.error(
                                                context,
                                                message: state.error,
                                              );
                                            }
                                          },
                                          builder: (context, state) {
                                            return CustomElevatedButton(
                                              title: locale.login,
                                              isLoading: state is LoginLoading,
                                              onPressed: () {
                                                if (formKey.currentState!
                                                    .validate()) {
                                                  context.read<LoginBloc>().add(
                                                    SendInitiateLogin(),
                                                  );
                                                }
                                              },
                                            );
                                          },
                                        ),

                                        SizedBox(height: 24.h),

                                        // 🔹 Activate Account Link
                                        Wrap(
                                          alignment: WrapAlignment.center,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              locale.no_active_account,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => context.push(
                                                Routes.verifyEmailPath,
                                              ),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w,
                                                ),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: Text(
                                                locale.activate,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
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
                                ),
                              ),

                              const Spacer(flex: 2),
                            ],
                          ),
                        ),
                      ),
                    ],
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
