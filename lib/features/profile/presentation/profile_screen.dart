import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../../../core/enums/app_language.dart';
import '../../../core/utils/responsive_layout.dart';
import '../models/user.dart';
import '../../language/bloc/language/language_bloc.dart';
import '../bloc/profile/profile_bloc.dart';
import 'widgets/profile_info_card.dart';
import '../widgets/profile_logout_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          UnifiedSnackbar.error(context, message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const LoadingWidget();
            }

            if (state is ProfileError) {
              return ErrorStateWidget(
                message: state.message,
                onRetry: () =>
                    context.read<ProfileBloc>().add(const LoadProfile()),
              );
            }

            if (state is ProfileLoaded) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16.r : 24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isMobile)
                      Text(
                        locale.profile,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                    if (!isMobile) SizedBox(height: 24.h),

                    if (state.isOffline) _buildOfflineWarning(context),

                    // Main Content Grid for Web/Tablet
                    isMobile
                        ? _buildMobileProfile(context, state.user, locale)
                        : _buildWebProfile(context, state.user, locale),

                    SizedBox(height: 80.h), // Space for floating bottom bar
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildOfflineWarning(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.warning),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                S.of(context).offline_mode,
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileProfile(BuildContext context, User user, S locale) {
    return Column(
      children: [
        ProfileInfoCard(user: user),
        SizedBox(height: 20.h),
        _buildMenuSection(context, locale),
      ],
    );
  }

  Widget _buildWebProfile(BuildContext context, User user, S locale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: ProfileInfoCard(user: user)),
        SizedBox(width: 24.w),
        Expanded(flex: 3, child: _buildMenuSection(context, locale)),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, S locale) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _ProfileMenuTile(
            icon: Icons.language_rounded,
            title: locale.language,
            onTap: () => _showLanguageSelection(context),
          ),
          const Divider(height: 1),
          _ProfileMenuTile(
            icon: Icons.notifications_outlined,
            title: locale.notifications,
            onTap: () {},
          ),
          const Divider(height: 1),
          _ProfileMenuTile(
            icon: Icons.security_rounded,
            title: "Security Settings", // TODO: Add to arb
            onTap: () {},
          ),
          const Divider(height: 1),
          _ProfileMenuTile(
            icon: Icons.logout_rounded,
            title: locale.log_out,
            isDestructive: true,
            onTap: () => ProfileLogoutDialog.show(context),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                S.of(context).language,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: const Icon(
                  Icons.language_rounded,
                  color: AppColors.primary,
                ),
                title: Text(S.of(context).arabic, style: const TextStyle()),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<LanguageBloc>().add(
                    const ChangeLanguage(AppLanguage.arabic),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.language_rounded,
                  color: AppColors.primary,
                ),
                title: Text(S.of(context).english, style: const TextStyle()),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<LanguageBloc>().add(
                    const ChangeLanguage(AppLanguage.english),
                  );
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.1)
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
          size: 20.sp,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: isDestructive ? AppColors.error : AppColors.primaryText,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 22.sp,
        color: AppColors.secondaryText.withValues(alpha: 0.5),
      ),
    );
  }
}
