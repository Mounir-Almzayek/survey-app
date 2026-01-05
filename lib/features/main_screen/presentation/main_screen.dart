import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../home/presentation/home_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../custody/presentation/custody_page.dart';
import '../bloc/main_navigation/main_navigation_bloc.dart';
import '../models/main_nav_tab.dart';
import '../widgets/main_drawer.dart';
import '../widgets/main_sidebar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainNavigationBloc, MainNavigationState>(
      builder: (context, state) {
        return ResponsiveLayout.isMobile(context)
            ? _MobileLayout(currentTab: state.currentTab)
            : _WebLayout(currentTab: state.currentTab);
      },
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final MainNavTab currentTab;
  const _MobileLayout({required this.currentTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: CustomAppBar(
        title: currentTab.label(S.of(context)),
        showDrawerButton: true,
      ),
      body: Stack(
        children: [
          _buildPage(currentTab),
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 20.h,
            child: _FloatingBottomBar(
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
            style: GoogleFonts.cairo(
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
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    "Field Team",
                    style: GoogleFonts.cairo(
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
      return const Center(child: Text("Assigned Surveys")); // Placeholder
    case MainNavTab.custody:
      return const CustodyPage();
    case MainNavTab.profile:
      return const ProfilePage();
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.secondaryText,
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
