import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/models/survey/survey_model.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/l10n/generated/l10n.dart';

class SurveyIntroWidget extends StatefulWidget {
  final Survey survey;
  final VoidCallback onStart;
  final bool isLoading;

  const SurveyIntroWidget({
    super.key,
    required this.survey,
    required this.onStart,
    this.isLoading = false,
  });

  @override
  State<SurveyIntroWidget> createState() => _SurveyIntroWidgetState();
}

class _SurveyIntroWidgetState extends State<SurveyIntroWidget>
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
    final title = widget.survey.title ?? "";
    final intro = widget.survey.greetingMessage ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Decorative background circles
          Positioned(
            top: -100.h,
            right: -50.w,
            child: _buildCircle(300.r, AppColors.primary.withOpacity(0.05)),
          ),
          Positioned(
            bottom: -50.h,
            left: -80.w,
            child: _buildCircle(250.r, AppColors.primary.withOpacity(0.03)),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Hero Icon Animation
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
                        padding: EdgeInsets.all(30.r),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 90.r,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 48.h),

                  // Title Animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Message Animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            intro,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 32.h),
                          _buildMetadataRow(context),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

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
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CustomElevatedButton(
                          onPressed: widget.isLoading ? null : widget.onStart,
                          title: s.start_survey.toUpperCase(),
                          isLoading: widget.isLoading,
                          width: double.infinity,
                          height: 56.h,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildMetadataRow(BuildContext context) {
    final s = S.of(context);

    int questionCount = 0;
    if (widget.survey.sections != null) {
      for (var section in widget.survey.sections!) {
        questionCount += section.questions?.length ?? 0;
      }
    }

    final sectionCount = widget.survey.sections?.length ?? 0;
    final minutes = widget.survey.minimumResponseTimeMinutes ?? 5;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 24.w,
      runSpacing: 16.h,
      children: [
        _buildInfoItem(
          index: 0,
          icon: Icons.help_outline_rounded,
          text: s.questions_count(questionCount),
        ),
        _buildInfoItem(
          index: 1,
          icon: Icons.access_time_rounded,
          text: s.minutes_count(minutes),
        ),
        _buildInfoItem(
          index: 2,
          icon: Icons.list_rounded,
          text: s.sections_count(sectionCount),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required int index,
    required IconData icon,
    required String text,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  0.4 + (index * 0.1),
                  0.8 + (index * 0.1),
                  curve: Curves.easeOutBack,
                ),
              ),
            ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primaryText.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              icon,
              size: 20.sp,
              color: AppColors.primaryText.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
