import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../assignment/bloc/assignments_list/assignments_list_bloc.dart';
import '../../public_links/presentation/widgets/public_links_section.dart';
import '../bloc/home_stats/home_stats_bloc.dart';
import '../bloc/home_stats/home_stats_event.dart';
import '../bloc/home_stats/home_stats_state.dart';
import 'widgets/dashboard_floating_menu.dart';
import 'widgets/survey_stats_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ScrollController _scrollController;

  // Keys for dashboard sections tracking
  final _analysisKey = GlobalKey(debugLabel: 'analysis');
  final _demographicsKey = GlobalKey(debugLabel: 'demographics');
  final _metricsKey = GlobalKey(debugLabel: 'metrics');
  final _syncKey = GlobalKey(debugLabel: 'sync');

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AssignmentsListBloc>().add(LoadAssignments());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    // Responsive values
    final horizontalPadding = context.responsive(
      20.w,
      tablet: 32.w,
      desktop: 32.0,
    );
    final headerFontSize = context.adaptiveFont(22.sp);

    return BlocProvider(
      create: (context) => HomeStatsBloc()..add(LoadHomeStats()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<HomeStatsBloc, HomeStatsState>(
          builder: (context, state) {
            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    context.read<HomeStatsBloc>().add(LoadHomeStats());
                  },
                  displacement: 40.h,
                  color: AppColors.primary,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: CustomScrollView(
                        controller: _scrollController,
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
                                  desktop: 40.0,
                                ),
                                horizontalPadding,
                                context.responsive(
                                  32.h,
                                  tablet: 48.h,
                                  desktop: 40.0,
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
                                  const SizedBox(height: 8),
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
                          // Desktop: single column so all dashboard elements (metrics, survey analysis,
                          // demographics, sync) appear and scroll; no split that hides content.
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildStatsContent(context, state),
                                  SizedBox(
                                    height: context.responsive(
                                      32.h,
                                      tablet: 40.h,
                                      desktop: 48.0,
                                    ),
                                  ),
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
                ),

                // Interactive Floating Navigation Menu
                if (state is HomeStatsLoaded)
                  DashboardFloatingMenu(
                    scrollController: _scrollController,
                    sections: [
                      DashboardSectionNode(
                        key: _analysisKey,
                        label: s.statistics,
                        icon: Icons.analytics_outlined,
                      ),
                      DashboardSectionNode(
                        key: _demographicsKey,
                        label: s.demographics_title,
                        icon: Icons.people_outline,
                      ),
                      DashboardSectionNode(
                        key: _metricsKey,
                        label: s.statistics,
                        icon: Icons.speed_outlined,
                      ),
                      DashboardSectionNode(
                        key: _syncKey,
                        label: s.sync_status,
                        icon: Icons.sync_outlined,
                      ),
                    ],
                  ),
              ],
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
      return SurveyStatsWidget(
        stats: state.stats,
        analysisKey: _analysisKey,
        demographicsKey: _demographicsKey,
        metricsKey: _metricsKey,
        syncKey: _syncKey,
      );
    }
    return const SizedBox.shrink();
  }
}
