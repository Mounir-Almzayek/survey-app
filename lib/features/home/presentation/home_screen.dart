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
    final isMobile = ResponsiveLayout.isMobile(context);
    final s = S.of(context);

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
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // App Bar / Header Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 20.w : 24.w,
                        24.h,
                        isMobile ? 20.w : 24.w,
                        32.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.welcome_back_researcher,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryText,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            s.home_survey_status_subtitle,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Statistics Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20.w : 24.w,
                      ),
                      child: _buildStatsContent(context, state),
                    ),
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: 32.h)),

                  // Public Links Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20.w : 24.w,
                      ),
                      child: const PublicLinksSection(),
                    ),
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: 120.h)),
                ],
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
