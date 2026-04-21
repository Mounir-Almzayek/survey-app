import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/custom_elevated_button.dart';

/// Completion scaffold for the public-link answering flow. Shows a success
/// celebration when the response was accepted, or a rejection message
/// (with [rejectionReason]) when the server flagged it.
///
/// On the success path, [goodbyeMessage] (set by the survey author and
/// piped through from the resolve call) takes precedence over the default
/// localized "Thank you" copy.
class AnsweringCompletionView extends StatefulWidget {
  final String? rejectionReason;
  final String goodbyeMessage;

  const AnsweringCompletionView({
    super.key,
    this.rejectionReason,
    this.goodbyeMessage = '',
  });

  bool get _isRejected =>
      rejectionReason != null && rejectionReason!.isNotEmpty;

  @override
  State<AnsweringCompletionView> createState() =>
      _AnsweringCompletionViewState();
}

class _AnsweringCompletionViewState extends State<AnsweringCompletionView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
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
    final isRejected = widget._isRejected;
    final accent = isRejected ? AppColors.error : AppColors.success;

    final title = isRejected ? s.response_not_accepted : s.thank_you;
    final body = isRejected
        ? widget.rejectionReason!
        : (widget.goodbyeMessage.isNotEmpty
            ? widget.goodbyeMessage
            : s.response_submitted_successfully);
    final icon = isRejected
        ? Icons.cancel_rounded
        : Icons.check_circle_rounded;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: context.isPhoneLandscape ? null : 1.sh,
          child: Stack(
            children: [
              Positioned(
                top: -100.h,
                right: -50.w,
                child: _buildCircle(300.r, accent.withValues(alpha: 0.05)),
              ),
              Positioned(
                bottom: -50.h,
                left: -80.w,
                child: _buildCircle(250.r, accent.withValues(alpha: 0.03)),
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
                      _buildIcon(icon, accent),
                      SizedBox(height: context.isPhoneLandscape ? 16.h : 48.h),
                      _buildTitle(context, title),
                      SizedBox(height: context.isPhoneLandscape ? 12.h : 20.h),
                      _buildBody(context, body),
                      if (!context.isPhoneLandscape) const Spacer(flex: 3),
                      if (context.isPhoneLandscape) SizedBox(height: 32.h),
                      _buildButton(context, s, accent),
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

  Widget _buildIcon(IconData icon, Color color) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _controller.drive(
          Tween(begin: 0.8, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
        ),
        child: Container(
          padding:
              EdgeInsets.all(context.isPhoneLandscape ? 15.r : 30.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: context.adaptiveIcon(
              context.isPhoneLandscape ? 40.sp : 90.sp,
            ),
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String title) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          title,
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
    );
  }

  Widget _buildBody(BuildContext context, String body) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          body,
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
    );
  }

  Widget _buildButton(BuildContext context, S s, Color accent) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: CustomElevatedButton(
            onPressed: () => context.go(Routes.splashPath),
            title: s.back_to_home,
            width: double.infinity,
            height: context.isPhoneLandscape ? 44.h : 56.h,
            fontSize: context.adaptiveFont(
              context.isPhoneLandscape ? 14.sp : 16.sp,
            ),
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
