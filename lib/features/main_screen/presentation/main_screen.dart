import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../assignment/presentation/pages/assignments_page.dart';
import '../../home/presentation/home_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../device_location/bloc/device_location/device_location_bloc.dart';
import '../../device_location/bloc/device_location/device_location_event.dart';
import '../../device_location/bloc/device_location/device_location_state.dart';
import '../../custody/presentation/custody_page.dart';
import '../bloc/main_navigation/main_navigation_bloc.dart';
import '../bloc/nav_visibility/nav_visibility_cubit.dart';
import '../models/main_nav_tab.dart';
import '../models/nav_visibility_context.dart';
import '../widgets/main_drawer.dart';
import '../widgets/main_sidebar.dart';
import 'widgets/floating_bottom_bar.dart';
import 'widgets/zoom_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ZoomDrawerController _drawerController = ZoomDrawerController();
  bool _isSidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  void _startLocationTracking() {
    context.read<DeviceLocationBloc>().add(const StartLocationTrackingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DeviceLocationBloc, DeviceLocationState>(
          listener: (context, state) {
            if (state is DeviceLocationWarningLogout) {
              // Forced logout logic if needed
            }
          },
        ),
      ],
      child: BlocBuilder<NavVisibilityCubit, NavVisibilityContext?>(
        builder: (context, ctx) {
          return BlocBuilder<MainNavigationBloc, MainNavigationState>(
            builder: (context, state) {
              if (ctx != null) {
                final visible = visibleTabs(ctx);
                if (visible.isNotEmpty &&
                    !visible.contains(state.currentTab)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      context.read<MainNavigationBloc>().add(
                            ChangeTab(visible.first),
                          );
                    }
                  });
                }
              }
              if (context.shouldShowSideBar) {
                return Scaffold(
                  body: Row(
                    children: [
                      MainSidebar(
                        selectedTab: state.currentTab,
                        isCollapsed: _isSidebarCollapsed,
                        onTabChanged: (tab) {
                          context
                              .read<MainNavigationBloc>()
                              .add(ChangeTab(tab));
                        },
                      ),
                      const VerticalDivider(width: 1, thickness: 1),
                      Expanded(
                        child: Scaffold(
                          appBar: CustomAppBar(
                            title: state.currentTab.label(S.of(context)),
                            showDrawerButton: false,
                            actions: [
                              IconButton(
                                icon: Icon(
                                  _isSidebarCollapsed
                                      ? Icons.menu_open_rounded
                                      : Icons.menu_rounded,
                                  color: AppColors.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isSidebarCollapsed =
                                        !_isSidebarCollapsed;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                          body: _buildPage(state.currentTab),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ZoomDrawer(
                controller: _drawerController,
                menuScreen: const MainDrawer(),
                mainScreen: _MobileLayout(
                  currentTab: state.currentTab,
                  drawerController: _drawerController,
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }
}

class _MobileLayout extends StatelessWidget {
  final MainNavTab currentTab;
  final ZoomDrawerController drawerController;

  const _MobileLayout({
    required this.currentTab,
    required this.drawerController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: currentTab.label(S.of(context)),
        showDrawerButton: true,
        onDrawerPressed: drawerController.toggle,
      ),
      body: Stack(
        children: [
          _buildPage(currentTab),
          Positioned(
            left: 0,
            right: 0,
            bottom: context.responsive(20.h, tablet: 24.h, desktop: 32.h),
            child: context.isPhoneLandscape
                ? const SizedBox.shrink() // Hide bottom bar on phone landscape
                : Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: context.responsive(
                          1.sw - 40.w,
                          tablet: 300.w,
                          desktop: 400.w,
                        ),
                      ),
                      child: FloatingBottomBar(
                        currentTab: currentTab,
                        onTabChanged: (tab) {
                          context.read<MainNavigationBloc>().add(
                            ChangeTab(tab),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

Widget _buildPage(MainNavTab tab) {
  switch (tab) {
    case MainNavTab.home:
      return const HomePage();
    case MainNavTab.surveys:
      return const AssignmentsPage();
    case MainNavTab.custody:
      return const CustodyPage();
    case MainNavTab.profile:
      return const ProfilePage();
  }
}
