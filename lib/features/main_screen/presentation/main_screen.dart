import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/services/device_local_metadata_service.dart';
import '../../assignment/presentation/pages/assignments_page.dart';
import '../../home/presentation/home_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../device_location/bloc/device_location/device_location_bloc.dart';
import '../../device_location/bloc/device_location/device_location_event.dart';
import '../../device_location/bloc/device_location/device_location_state.dart';
import '../../custody/presentation/custody_page.dart';
import '../bloc/main_navigation/main_navigation_bloc.dart';
import '../models/main_nav_tab.dart';
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

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  Future<void> _startLocationTracking() async {
    // Get device ID and assignment ID from DeviceLocalMetadataService
    final metadataService = DeviceLocalMetadataService();
    final deviceId = await metadataService.getPhysicalDeviceId();
    if (deviceId == null) {
      return; // No device ID, skip location tracking
    }

    final assignmentId = await metadataService.getAssignmentId();

    // Start location tracking
    if (mounted) {
      context.read<DeviceLocationBloc>().add(
        StartLocationTrackingEvent(
          deviceId: deviceId,
          assignmentId: assignmentId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DeviceLocationBloc, DeviceLocationState>(
          listener: (context, state) {
            if (state is DeviceLocationWarningLogout) {
              // Force logout when warning or outside zone
              // This will be handled by the background service
            } else if (state is DeviceLocationError) {
              // Log error but don't stop tracking
            }
          },
        ),
      ],
      child: BlocBuilder<MainNavigationBloc, MainNavigationState>(
        builder: (context, state) {
          if (ResponsiveLayout.isMobile(context)) {
            return ZoomDrawer(
              controller: _drawerController,
              menuScreen: const MainDrawer(),
              mainScreen: _MobileLayout(
                currentTab: state.currentTab,
                drawerController: _drawerController,
              ),
            );
          }
          return _WebLayout(currentTab: state.currentTab);
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
            left: 20.w,
            right: 20.w,
            bottom: 20.h,
            child: FloatingBottomBar(
              currentTab: currentTab,
              onTabChanged: (tab) {
                context.read<MainNavigationBloc>().add(ChangeTab(tab));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WebLayout extends StatelessWidget {
  final MainNavTab currentTab;
  const _WebLayout({required this.currentTab});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveLayout.isTablet(context);

    return Scaffold(
      body: Row(
        children: [
          MainSidebar(
            selectedTab: currentTab,
            isCollapsed: isTablet,
            onTabChanged: (tab) {
              context.read<MainNavigationBloc>().add(ChangeTab(tab));
            },
          ),
          Expanded(
            child: Column(
              children: [
                _WebHeader(currentTab: currentTab),
                Expanded(child: _buildPage(currentTab)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WebHeader extends StatelessWidget {
  final MainNavTab currentTab;
  const _WebHeader({required this.currentTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (ResponsiveLayout.isTablet(context)) ...[
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            SizedBox(width: 8.w),
          ],
          Text(
            currentTab.label(S.of(context)),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const Spacer(),
          _HeaderIcon(icon: Icons.search_rounded, onTap: () {}),
          SizedBox(width: 8.w),
          _HeaderIcon(icon: Icons.notifications_none_rounded, onTap: () {}),
          SizedBox(width: 16.w),
          Container(
            width: 1,
            height: 24.h,
            color: AppColors.border.withValues(alpha: 0.8),
          ),
          SizedBox(width: 16.w),
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Researcher",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    "Field Team",
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.secondaryText,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              CircleAvatar(
                radius: 16.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 18.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: AppColors.muted.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: AppColors.secondaryText, size: 20.sp),
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
