import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/logo_rectangle.dart';
import '../../../core/enums/app_language.dart';
import '../../language/bloc/language/language_bloc.dart';
import '../../profile/widgets/profile_logout_dialog.dart';
import '../../../core/queue/services/request_queue_service.dart';
import '../../../core/queue/presentation/queue_session/queue_session_bloc.dart';
import '../../../core/queue/presentation/queue_summary_dialog.dart';
import '../bloc/main_navigation/main_navigation_bloc.dart';
import '../models/main_nav_tab.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return SafeArea(
      child: Drawer(
        width: 0.75.sw,
        child: BlocBuilder<MainNavigationBloc, MainNavigationState>(
          builder: (context, navState) {
            final selectedTab = navState.currentTab;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.h,
                    horizontal: 50.w,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  child: LogoRectangle(
                    big: false,
                    isFlat: true,
                    width: 130.w,
                    height: 80.h,
                  ),
                ),
                // Menu Items
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(title: locale.main_menu),
                        SizedBox(height: 10.h),
                        ...MainNavTab.values.map(
                          (tab) => _DrawerItem(
                            icon: tab.icon,
                            title: tab.label(locale),
                            isSelected: selectedTab == tab,
                            onPressed: () {
                              Navigator.pop(context);
                              context.read<MainNavigationBloc>().add(
                                ChangeTab(tab),
                              );
                            },
                          ),
                        ),
                        const Divider(),
                        _DrawerItem(
                          icon: Icons.cloud_queue_rounded,
                          title: locale.queue_summary_title,
                          isSelected: false,
                          onPressed: () async {
                            Navigator.pop(context);
                            final all =
                                await RequestQueueService.getAllRequests();
                            if (all.isEmpty) return;

                            final initialMap = {
                              for (final item in all) item.id: item,
                            };
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (ctx) => BlocProvider(
                                  create: (_) => QueueSessionBloc(
                                    initialItems: initialMap,
                                  ),
                                  child: const QueueSummaryDialog(),
                                ),
                              );
                            }
                          },
                        ),
                        _DrawerItem(
                          icon: Icons.language_rounded,
                          title: locale.language,
                          isSelected: false,
                          trailingText:
                              Localizations.localeOf(context).languageCode ==
                                  'ar'
                              ? locale.arabic
                              : locale.english,
                          onPressed: () {
                            Navigator.pop(context);
                            _showLanguageSelection(context);
                          },
                        ),
                        _DrawerItem(
                          icon: Icons.logout_rounded,
                          title: locale.log_out,
                          isSelected: false,
                          onPressed: () {
                            Navigator.pop(context);
                            ProfileLogoutDialog.show(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showLanguageSelection(BuildContext context) {
    final locale = S.of(context);
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(locale.arabic),
              onTap: () {
                Navigator.pop(context);
                context.read<LanguageBloc>().add(
                  const ChangeLanguage(AppLanguage.arabic),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(locale.english),
              onTap: () {
                Navigator.pop(context);
                context.read<LanguageBloc>().add(
                  const ChangeLanguage(AppLanguage.english),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onPressed;
  final String? trailingText;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onPressed,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        onTap: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.secondaryText,
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            color: isSelected ? AppColors.primary : AppColors.primaryText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14.sp,
          ),
        ),
        trailing: trailingText != null
            ? Text(
                trailingText!,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              )
            : isSelected
            ? Icon(Icons.chevron_right, color: AppColors.primary)
            : null,
      ),
    );
  }
}
