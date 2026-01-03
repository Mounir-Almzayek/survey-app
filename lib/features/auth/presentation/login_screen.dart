import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/custom_elevated_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/logo_rectangle.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../bloc/login/login_bloc.dart';

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
              child: Container(
                width: 400.w,
                height: 400.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryStart.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -50.h,
              left: -50.w,
              child: Container(
                width: 300.w,
                height: 300.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryEnd.withOpacity(0.05),
                ),
              ),
            ),

            // 🔹 Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 🔹 Logo Section
                      const LogoRectangle(big: true),
                      SizedBox(height: 32.h),

                      // 🔹 Form Title
                      Text(
                        locale.researcher_login,
                        style: GoogleFonts.cairo(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        locale.enter_details,
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // 🔹 Login Card
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
                                onChanged: (value) {
                                  context.read<LoginBloc>().add(
                                    UpdateEmail(value),
                                  );
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return locale.no_user_name;
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20.h),
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
                                  if (value == null || value.isEmpty) {
                                    return locale.no_password;
                                  }
                                  return null;
                                },
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
                                  } else if (state is LoginInitiateSuccess) {
                                    // Automatically proceed to verify for now
                                    // In a real scenario, this might wait for user interaction or biometrics
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
                                      if (formKey.currentState!.validate()) {
                                        context.read<LoginBloc>().add(
                                          SendInitiateLogin(),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
