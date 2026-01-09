import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/logo_rectangle.dart';
import '../models/main_nav_tab.dart';

class MainSidebar extends StatelessWidget {
  final MainNavTab selectedTab;
  final Function(MainNavTab) onTabChanged;
  final bool isCollapsed;

  const MainSidebar({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 80.w : 260.w,
      decoration: BoxDecoration(
        color: Colors.white,
        border: BorderDirectional(
          end: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo Area
          Container(
            height: 100.h,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            alignment: isCollapsed
                ? Alignment.center
                : AlignmentDirectional.centerStart,
            child: isCollapsed
                ? const LogoRectangle(big: false)
                : Row(
                    children: [
                      const LogoRectangle(big: false),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          "KAC Survey",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              children: MainNavTab.values.map((tab) {
                final isSelected = selectedTab == tab;
                return _SidebarItem(
                  icon: tab.icon,
                  label: tab.label(locale),
                  isSelected: isSelected,
                  isCollapsed: isCollapsed,
                  onTap: () => onTabChanged(tab),
                );
              }).toList(),
            ),
          ),

          // Footer / User Info (Optional)
          if (!isCollapsed)
            Container(
              padding: EdgeInsets.all(20.r),
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18.r,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Researcher",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          Text(
                            "Field Team",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 0 : 16.w,
            vertical: 12.h,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.secondaryText,
                size: 22.sp,
              ),
              if (!isCollapsed) ...[
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primaryText,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
