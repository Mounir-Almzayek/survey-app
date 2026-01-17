import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/logo_rectangle.dart';
import '../../../core/enums/app_language.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../language/bloc/language/language_bloc.dart';
import '../../profile/widgets/profile_logout_dialog.dart';
import '../../../core/queue/services/request_queue_service.dart';
import '../../../core/queue/presentation/queue_session/queue_session_bloc.dart';
import '../../../core/queue/presentation/queue_summary_dialog.dart';
import '../bloc/main_navigation/main_navigation_bloc.dart';
import '../models/main_nav_tab.dart';
import '../presentation/widgets/zoom_drawer.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  ZoomDrawerController? _zoomDrawerController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newController = ZoomDrawer.of(context);
    if (newController != _zoomDrawerController) {
      _zoomDrawerController?.removeListener(_onDrawerStateChanged);
      _zoomDrawerController = newController;
      _zoomDrawerController?.addListener(_onDrawerStateChanged);
    }
  }

  void _onDrawerStateChanged() {
    if (_zoomDrawerController != null && _zoomDrawerController!.isOpen) {
      _staggerController.forward(from: 0.0);
    } else {
      _staggerController.reverse();
    }
  }

  @override
  void dispose() {
    _zoomDrawerController?.removeListener(_onDrawerStateChanged);
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.responsive(40.h, tablet: 50.h, desktop: 60.h),
              horizontal: context.responsive(24.w, tablet: 30.w, desktop: 36.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo or Header
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: 16.w,
                    bottom: 40.h,
                  ),
                  child: LogoRectangle(
                    big: false,
                    isFlat: true,
                    width: context.responsive(
                      100.w,
                      tablet: 120.w,
                      desktop: 140.w,
                    ),
                    height: context.responsive(
                      50.h,
                      tablet: 60.h,
                      desktop: 70.h,
                    ),
                  ),
                ),

                // Menu Items
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAnimatedItem(
                          0,
                          _SectionHeader(
                            title: locale.main_menu,
                            isLight: true,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        ...MainNavTab.values.asMap().entries.map(
                          (entry) => _buildAnimatedItem(
                            entry.key + 1,
                            _DrawerItem(
                              icon: entry.value.icon,
                              title: entry.value.label(locale),
                              isSelected: false,
                              isLight: true,
                              onPressed: () {
                                ZoomDrawer.of(context)?.close();
                                context.read<MainNavigationBloc>().add(
                                  ChangeTab(entry.value),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: const Divider(color: Colors.white24),
                        ),
                        _buildAnimatedItem(
                          MainNavTab.values.length + 2,
                          _DrawerItem(
                            icon: Icons.cloud_queue_rounded,
                            title: locale.queue_summary_title,
                            isSelected: false,
                            isLight: true,
                            onPressed: () async {
                              ZoomDrawer.of(context)?.close();
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
                        ),
                        _buildAnimatedItem(
                          MainNavTab.values.length + 3,
                          _DrawerItem(
                            icon: Icons.language_rounded,
                            title: locale.language,
                            isSelected: false,
                            isLight: true,
                            trailingText:
                                Localizations.localeOf(context).languageCode ==
                                    'ar'
                                ? locale.arabic
                                : locale.english,
                            onPressed: () {
                              ZoomDrawer.of(context)?.close();
                              _showLanguageSelection(context);
                            },
                          ),
                        ),
                        _buildAnimatedItem(
                          MainNavTab.values.length + 4,
                          _DrawerItem(
                            icon: Icons.logout_rounded,
                            title: locale.log_out,
                            isSelected: false,
                            isLight: true,
                            onPressed: () {
                              ZoomDrawer.of(context)?.close();
                              ProfileLogoutDialog.show(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: 16.w,
                    bottom: 20.h,
                  ),
                  child: Text(
                    "v1.0.0",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: context.adaptiveFont(11.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final animationPercent = _staggerController.value;
        final start = index * 0.1;
        final end = start + 0.4;
        final opacity = (animationPercent - start) / (end - start);

        final isRtl = Directionality.of(context) == TextDirection.rtl;
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(
              (isRtl ? -50 : 50) * (1.0 - opacity.clamp(0.0, 1.0)),
              0,
            ),
            child: child,
          ),
        );
      },
      child: child,
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
  final bool isLight;
  const _SectionHeader({required this.title, this.isLight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: context.adaptiveFont(13.sp),
          fontWeight: FontWeight.bold,
          color: isLight ? Colors.white70 : AppColors.primary,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final bool isLight;
  final VoidCallback onPressed;
  final String? trailingText;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onPressed,
    this.isLight = false,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLight
        ? Colors.white
        : (isSelected ? AppColors.primary : AppColors.primaryText);
    final iconColor = isLight
        ? Colors.white70
        : (isSelected ? AppColors.primary : AppColors.secondaryText);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isSelected
            ? (isLight
                  ? Colors.white.withOpacity(0.2)
                  : AppColors.primary.withValues(alpha: 0.1))
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
          color: iconColor,
          size: context.adaptiveIcon(22.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: context.adaptiveFont(13.sp),
          ),
        ),
        trailing: trailingText != null
            ? Text(
                trailingText!,
                style: TextStyle(
                  color: isLight ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              )
            : isSelected
            ? Icon(
                Icons.chevron_right,
                color: isLight ? Colors.white : AppColors.primary,
              )
            : null,
      ),
    );
  }
}
