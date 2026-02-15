import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../../../core/utils/responsive_layout.dart';
import '../models/researcher_profile_response_model.dart';
import '../bloc/profile/profile_bloc.dart';
import 'widgets/researcher_basic_info_card.dart';
import 'widgets/supervisor_info_card.dart';
import 'widgets/assignments_list_card.dart';
import 'widgets/profile_settings_section.dart';

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
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.responsive(
                      1.sw,
                      tablet: 600.0,
                      desktop: 1000.0,
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(
                      context.responsive(16.r, tablet: 24.r, desktop: 32.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isMobile)
                          Text(
                            locale.profile,
                            style: TextStyle(
                              fontSize: context.adaptiveFont(20.sp),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                        if (!isMobile) SizedBox(height: 24.h),

                        if (state.isOffline) _buildOfflineWarning(context),

                        // Main Content Grid
                        _buildProfileContent(context, state.profile, locale),

                        SizedBox(
                          height: 100.h,
                        ), // Space for floating bottom bar
                      ],
                    ),
                  ),
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
            Icon(
              Icons.wifi_off_rounded,
              color: AppColors.warning,
              size: context.adaptiveIcon(18.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                S.of(context).offline_mode,
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: context.adaptiveFont(12.sp),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    ResearcherProfileResponseModel profile,
    S locale,
  ) {
    // final isMobile = ResponsiveLayout.isMobile(context); // Not used anymore

    if (ResponsiveLayout.isDesktop(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                ResearcherBasicInfoCard(user: profile.user),
                SizedBox(height: 20.h),
                SupervisorInfoCard(supervisor: profile.supervisor),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                AssignmentsListCard(assignments: profile.assignments),
                SizedBox(height: 20.h),
                const ProfileSettingsSection(),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        ResearcherBasicInfoCard(user: profile.user),
        SizedBox(height: 20.h),
        SupervisorInfoCard(supervisor: profile.supervisor),
        SizedBox(height: 20.h),
        AssignmentsListCard(assignments: profile.assignments),
        SizedBox(height: 20.h),
        const ProfileSettingsSection(),
      ],
    );
  }
}
