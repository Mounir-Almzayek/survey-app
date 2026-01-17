import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/assets/assets.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? topTrailing;
  final bool showBackButton;

  const AuthScaffold({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.topTrailing,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
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
            // 🔹 Decorative Background Blobs
            Positioned(
              top: -100.h,
              right: -100.w,
              child: _buildBlob(
                context.responsive(400.w, tablet: 300.w),
                AppColors.primaryStart.withOpacity(0.05),
              ),
            ),
            Positioned(
              bottom: -50.h,
              left: -50.w,
              child: _buildBlob(
                context.responsive(400.w, tablet: 300.w),
                AppColors.primaryEnd.withOpacity(0.05),
              ),
            ),

            // 🔹 Main Content
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.responsive(24.w, tablet: 48.w),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: context.responsive(500.w, tablet: 450.w),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 🔹 Header Actions (Back & Trailing)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (showBackButton)
                                    IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  else
                                    const SizedBox.shrink(),
                                  if (topTrailing != null) topTrailing!,
                                ],
                              ),

                              const Spacer(flex: 1),

                              // 🔹 Global App Logo
                              Hero(
                                tag: 'app_logo',
                                child: Image.asset(
                                  Assets.logo1,
                                  width: context.responsive(
                                    100.w,
                                    tablet: 120.w,
                                  ),
                                  height: context.responsive(
                                    100.h,
                                    tablet: 120.h,
                                  ),
                                ),
                              ),
                              SizedBox(height: 32.h),

                              // 🔹 Title & Subtitle
                              if (title != null) ...[
                                Text(
                                  title!,
                                  style: TextStyle(
                                    fontSize: context.adaptiveFont(26.sp),
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    letterSpacing: -0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8.h),
                              ],
                              if (subtitle != null) ...[
                                Text(
                                  subtitle!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: context.adaptiveFont(14.sp),
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                SizedBox(height: 40.h),
                              ],

                              // 🔹 Content Card
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(
                                  context.responsive(24.w, tablet: 32.w),
                                ),
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
                                child: child,
                              ),

                              const Spacer(flex: 2),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
