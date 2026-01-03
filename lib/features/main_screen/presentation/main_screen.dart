import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_colors.dart';
import '../../home/presentation/home_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../profile/bloc/profile/profile_bloc.dart';
import '../bloc/main_navigation/main_navigation_bloc.dart';
import '../models/main_nav_tab.dart';
import '../widgets/main_drawer.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLogoutSuccess) {
          context.go(Routes.loginPath);
        }
      },
      child: BlocBuilder<MainNavigationBloc, MainNavigationState>(
        builder: (context, state) {
          return Scaffold(
            drawer: const MainDrawer(),
            body: Stack(
              children: [
                // Page Content
                _buildPage(state.currentTab),

                // Floating Bottom Navigation Bar
                Positioned(
                  left: 20.w,
                  right: 20.w,
                  bottom: 20.h,
                  child: _FloatingBottomBar(
                    currentTab: state.currentTab,
                    onTabChanged: (tab) {
                      context.read<MainNavigationBloc>().add(ChangeTab(tab));
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPage(MainNavTab tab) {
    switch (tab) {
      case MainNavTab.home:
        return const HomePage();
      case MainNavTab.profile:
        return const ProfilePage();
    }
  }
}

class _FloatingBottomBar extends StatelessWidget {
  final MainNavTab currentTab;
  final Function(MainNavTab) onTabChanged;

  const _FloatingBottomBar({
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: MainNavTab.values.map((tab) {
          final isSelected = currentTab == tab;
          return GestureDetector(
            onTap: () => onTabChanged(tab),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab.icon,
                    color: isSelected ? AppColors.primary : AppColors.textGrey,
                    size: 24.sp,
                  ),
                  if (isSelected) ...[
                    SizedBox(height: 4.h),
                    Container(
                      width: 4.w,
                      height: 4.h,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
