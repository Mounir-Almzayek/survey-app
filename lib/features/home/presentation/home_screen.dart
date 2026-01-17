import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../public_links/presentation/widgets/public_links_section.dart';
import '../bloc/home_stats/home_stats_bloc.dart';
import '../bloc/home_stats/home_stats_event.dart';
import '../bloc/home_stats/home_stats_state.dart';
import 'widgets/survey_stats_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    // Responsive values
    final horizontalPadding = context.responsive(
      20.w,
      tablet: 32.w,
      desktop: 48.w,
    );
    final headerFontSize = context.adaptiveFont(22.sp);

    return BlocProvider(
      create: (context) => HomeStatsBloc()..add(LoadHomeStats()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<HomeStatsBloc, HomeStatsState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeStatsBloc>().add(LoadHomeStats());
              },
              displacement: 40.h,
              color: AppColors.primary,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.responsive(1.sw, desktop: 1400.w),
                  ),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // App Bar / Header Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            context.responsive(
                              24.h,
                              tablet: 40.h,
                              desktop: 50.h,
                            ),
                            horizontalPadding,
                            context.responsive(
                              32.h,
                              tablet: 48.h,
                              desktop: 60.h,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.welcome_back_researcher,
                                style: TextStyle(
                                  fontSize: headerFontSize,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryText,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                s.home_survey_status_subtitle,
                                style: TextStyle(
                                  fontSize: context.adaptiveFont(13.sp),
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Content Section (Stats & Public Links)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: context.shouldShowSideBar
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left side: Statistics
                                    Expanded(
                                      flex: 4,
                                      child: _buildStatsContent(context, state),
                                    ),
                                    SizedBox(width: 32.w),
                                    // Right side: Public Links
                                    const Expanded(
                                      flex: 3,
                                      child: PublicLinksSection(),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildStatsContent(context, state),
                                    SizedBox(height: 32.h),
                                    const PublicLinksSection(),
                                  ],
                                ),
                        ),
                      ),

                      SliverToBoxAdapter(child: SizedBox(height: 180.h)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, HomeStatsState state) {
    if (state is HomeStatsLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: const LoadingWidget(),
      );
    } else if (state is HomeStatsError) {
      return ErrorStateWidget(
        message: state.message,
        onRetry: () => context.read<HomeStatsBloc>().add(LoadHomeStats()),
      );
    } else if (state is HomeStatsLoaded) {
      return SurveyStatsWidget(stats: state.stats);
    }
    return const SizedBox.shrink();
  }
}
