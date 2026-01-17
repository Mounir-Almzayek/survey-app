import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_pages.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../../profile/bloc/profile/profile_bloc.dart';
import '../service/background_location_service.dart';

class ZoneViolationListener extends StatefulWidget {
  final Widget child;

  const ZoneViolationListener({super.key, required this.child});

  @override
  State<ZoneViolationListener> createState() => _ZoneViolationListenerState();
}

class _ZoneViolationListenerState extends State<ZoneViolationListener> {
  StreamSubscription? _subscription;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _subscription = BackgroundLocationService().onZoneViolation.listen((
      message,
    ) {
      _showViolationDialog();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _showViolationDialog() {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    final navigatorContext = Pages.navigatorKey.currentContext;
    if (navigatorContext == null) {
      _isDialogShowing = false;
      return;
    }

    final locale = S.of(navigatorContext);

    showDialog(
      context: navigatorContext,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: _buildDialogContent(context, locale),
        ),
      ),
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  Widget _buildDialogContent(BuildContext context, S locale) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.gpp_maybe_rounded,
              color: AppColors.error,
              size: context.adaptiveIcon(48.sp),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            locale.zone_violation_title,
            style: TextStyle(
              fontSize: context.adaptiveFont(20.sp),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            locale.zone_violation_message,
            style: TextStyle(
              fontSize: context.adaptiveFont(14.sp),
              color: AppColors.secondaryText,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Text(
              locale.ok.toUpperCase(),
              style: TextStyle(fontSize: context.adaptiveFont(15.sp), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    // Check if context is still valid for bloc access
    if (mounted) {
      context.read<ProfileBloc>().add(Logout());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        final navigatorContext = Pages.navigatorKey.currentContext;
        if (state is ProfileLogoutSuccess) {
          if (navigatorContext != null && navigatorContext.mounted) {
            navigatorContext.go(Routes.loginPath);
          } else if (mounted) {
            context.go(Routes.loginPath);
          }
        } else if (state is ProfileError) {
          if (mounted) {
            UnifiedSnackbar.error(context, message: state.message);
            context.go(Routes.loginPath);
          }
        }
      },
      child: widget.child,
    );
  }
}
