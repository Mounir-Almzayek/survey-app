import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/logo_rectangle.dart';
import '../bloc/nav_visibility/nav_visibility_cubit.dart';
import '../models/main_nav_tab.dart';
import '../models/nav_visibility_context.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../language/bloc/language/language_bloc.dart';
import '../../../core/enums/app_language.dart';

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
      width: isCollapsed
          ? context.responsive(70.w, tablet: 40.w)
          : context.responsive(120.w, tablet: 70.w),
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
            height: context.responsive(100.h, tablet: 100.0, desktop: 120.0),
            padding: EdgeInsets.symmetric(
              horizontal: context.responsive(20.w, tablet: 16.0, desktop: 20.0),
            ),
            alignment: isCollapsed
                ? Alignment.center
                : AlignmentDirectional.centerStart,
            child: const LogoRectangle(big: false),
          ),

          // Menu Items
          Expanded(
            child: BlocBuilder<NavVisibilityCubit, NavVisibilityContext?>(
              builder: (context, ctx) {
                final tabs = ctx == null
                    ? MainNavTab.values
                    : visibleTabs(ctx);
                return ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.isDesktop ? 16.0 : 12.w,
                    vertical: context.isDesktop ? 16.0 : 10.h,
                  ),
                  children: tabs.map((tab) {
                    final isSelected = selectedTab == tab;
                    return _SidebarItem(
                      icon: tab.icon,
                      label: tab.label(locale),
                      isSelected: isSelected,
                      isCollapsed: isCollapsed,
                      onTap: () => onTabChanged(tab),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // Language Switcher Footer
          Container(
            padding: EdgeInsets.all(context.isDesktop ? 16.0 : 20.r),
            child: BlocBuilder<LanguageBloc, LanguageState>(
              builder: (context, state) {
                final isArabic = state.language == AppLanguage.arabic;
                return InkWell(
                  onTap: () {
                    context.read<LanguageBloc>().add(
                      ChangeLanguage(
                        isArabic ? AppLanguage.english : AppLanguage.arabic,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCollapsed ? 0 : 12.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: isCollapsed
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.language_rounded,
                          color: AppColors.primary,
                          size: context.adaptiveIcon(20.sp),
                        ),
                        if (!isCollapsed) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isArabic ? 'English' : 'العربية',
                              style: TextStyle(
                                fontSize: context.adaptiveFont(13.sp),
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: context.isDesktop ? 20.0 : 20.h),
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
      padding: EdgeInsets.only(bottom: context.isDesktop ? 12.0 : 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 0 : (context.isDesktop ? 16.0 : 16.w),
            vertical: context.isDesktop ? 14.0 : 12.h,
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
                size: context.adaptiveIcon(22.sp),
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: context.adaptiveFont(14.sp),
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
