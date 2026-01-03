import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/enums/app_language.dart';
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
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLogoutSuccess) {
          context.go(Routes.loginPath);
        } else if (state is ProfileError) {
          UnifiedSnackbar.error(context, message: state.message);
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(160.h),
          child: CustomAppBar(
            title: locale.profile,
            big: false,
            showDrawerButton: true,
          ),
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
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
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.isOffline)
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.wifi_off,
                                color: AppColors.warning,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  S.of(context).offline_mode,
                                  style: TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ProfileInfoCard(user: state.user),
                    SizedBox(height: 24.h),

                    // Language Selection
                    _ProfileMenuTile(
                      icon: Icons.language_outlined,
                      title: locale.language,
                      onTap: () => _showLanguageSelection(context),
                    ),
                    SizedBox(height: 12.h),

                    // Logout Button
                    _ProfileMenuTile(
                      icon: Icons.logout_rounded,
                      title: locale.log_out,
                      isDestructive: true,
                      onTap: () => ProfileLogoutDialog.show(context, () {
                        context.read<ProfileBloc>().add(const Logout());
                      }),
                    ),
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

  void _showLanguageSelection(BuildContext context) {
    // Reusing the same logic as the drawer for consistency
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(S.of(context).arabic),
              onTap: () {
                Navigator.pop(ctx);
                context.read<LanguageBloc>().add(
                  const ChangeLanguage(AppLanguage.arabic),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(S.of(context).english),
              onTap: () {
                Navigator.pop(ctx);
                context.read<LanguageBloc>().add(
                  const ChangeLanguage(AppLanguage.english),
                );
              },
            ),
          ],
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: isDestructive ? AppColors.error : AppColors.primaryText,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 20.sp,
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.5)
              : AppColors.textGrey,
        ),
      ),
    );
  }
}
