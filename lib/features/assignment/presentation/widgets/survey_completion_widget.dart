import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/models/survey/survey_model.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/l10n/generated/l10n.dart';
import 'package:go_router/go_router.dart';

class SurveyCompletionWidget extends StatefulWidget {
  final Survey survey;

  const SurveyCompletionWidget({super.key, required this.survey});

  @override
  State<SurveyCompletionWidget> createState() => _SurveyCompletionWidgetState();
}

class _SurveyCompletionWidgetState extends State<SurveyCompletionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final goodbye = widget.survey.goodbyeMessage ?? s.thank_you_for_response;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: context.isPhoneLandscape ? null : 1.sh,
          child: Stack(
            children: [
              // Decorative background circles
              Positioned(
                top: -100.h,
                right: -50.w,
                child: _buildCircle(300.r, AppColors.success.withOpacity(0.05)),
              ),
              Positioned(
                bottom: -50.h,
                left: -80.w,
                child: _buildCircle(250.r, AppColors.success.withOpacity(0.03)),
              ),

              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: context.isPhoneLandscape ? 20.h : 0,
                  ),
                  child: Column(
                    children: [
                      if (!context.isPhoneLandscape) const Spacer(flex: 2),

                      // Success Icon Animation
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _controller.drive(
                            Tween(
                              begin: 0.8,
                              end: 1.0,
                            ).chain(CurveTween(curve: Curves.elasticOut)),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(
                              context.isPhoneLandscape ? 15.r : 30.r,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: context.adaptiveIcon(
                                context.isPhoneLandscape ? 40.sp : 90.sp,
                              ),
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: context.isPhoneLandscape ? 16.h : 48.h),

                      // Title Animation
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            s.survey_completed,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: context.adaptiveFont(
                                context.isPhoneLandscape ? 20.sp : 28.sp,
                              ),
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: context.isPhoneLandscape ? 12.h : 20.h),

                      // Message Animation
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            goodbye,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: context.adaptiveFont(
                                context.isPhoneLandscape ? 13.sp : 16.sp,
                              ),
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),

                      if (!context.isPhoneLandscape) const Spacer(flex: 3),
                      if (context.isPhoneLandscape) SizedBox(height: 32.h),

                      // Button Animation
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, 0.5),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _controller,
                                  curve: const Interval(
                                    0.6,
                                    1.0,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              ),
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.success.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: CustomElevatedButton(
                              onPressed: () => context.pop(),
                              title: s.back_to_assignments.toUpperCase(),
                              width: double.infinity,
                              height: context.isPhoneLandscape ? 44.h : 56.h,
                              fontSize: context.adaptiveFont(
                                context.isPhoneLandscape ? 14.sp : 16.sp,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: context.isPhoneLandscape ? 20.h : 40.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
