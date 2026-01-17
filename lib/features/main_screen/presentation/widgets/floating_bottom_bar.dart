import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../models/main_nav_tab.dart';

class FloatingBottomBar extends StatelessWidget {
  final MainNavTab currentTab;
  final Function(MainNavTab) onTabChanged;

  const FloatingBottomBar({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.responsive(4.w, tablet: 6.w, desktop: 8.w),
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsive(8.w, tablet: 12.w, desktop: 16.w),
              vertical: context.responsive(8.h),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: MainNavTab.values.map((tab) {
                final isSelected = currentTab == tab;
                return GestureDetector(
                  onTap: () => onTabChanged(tab),
                  behavior: HitTestBehavior.opaque,
                  child: _AnimatedTabItem(tab: tab, isSelected: isSelected),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedTabItem extends StatelessWidget {
  final MainNavTab tab;
  final bool isSelected;

  const _AnimatedTabItem({required this.tab, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuart,
      padding: EdgeInsets.symmetric(
        horizontal: isSelected
            ? context.responsive(18.w, tablet: 12.w, desktop: 10.w)
            : context.responsive(12.w, tablet: 8.w, desktop: 6.w),
        vertical: context.responsive(10.h),
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: isSelected ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            child: Icon(
              isSelected ? tab.activeIcon : tab.icon,
              color: isSelected ? AppColors.primary : AppColors.secondaryText,
              size: context.adaptiveIcon(22.sp),
            ),
          ),
          if (isSelected) ...[
            SizedBox(height: 4.h),
            Flexible(
              child: Text(
                tab.label(S.of(context)),
                style: TextStyle(
                  fontSize: context.adaptiveFont(10.sp),
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
