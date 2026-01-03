import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/assets/assets.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/custom_elevated_button.dart';
import '../../splash/repositories/settings_local_repository.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
            // 🔹 Decorative Blobs (Inspired by Web GradientBlobs)
            Positioned(
              top: -100.h,
              right: -100.w,
              child: Container(
                width: 400.w,
                height: 400.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryStart.withOpacity(0.12),
                      AppColors.primaryStart.withOpacity(0),
                    ],
                  ),
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
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryEnd.withOpacity(0.12),
                      AppColors.primaryEnd.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),

            // 🔹 Main Content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // 🔹 Animated Logo
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Center(
                        child: Image.asset(
                          Assets.logo1,
                          fit: BoxFit.contain,
                          width: 100.w,
                          height: 100.h,
                        ),
                      ),
                    ),

                    SizedBox(height: 48.h),

                    // 🔹 Welcome Text
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            locale.welcome,
                            style: GoogleFonts.cairo(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            width: 60.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            locale.welcome_subtitle,
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              color: AppColors.secondaryText.withOpacity(0.8),
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // 🔹 Action Button
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: CustomElevatedButton(
                        title: locale.get_started,
                        onPressed: () {
                          SettingsLocalRepository.markAppAsOpened();
                          context.pushReplacement(Routes.loginPath);
                        },
                      ),
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
