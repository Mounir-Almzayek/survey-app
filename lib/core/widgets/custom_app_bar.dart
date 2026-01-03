import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../features/language/widgets/language_toggle.dart';
import '../styles/app_colors.dart';
import 'logo_rectangle.dart';

class CustomAppBar extends StatelessWidget {
  final bool big;
  final VoidCallback? onBackPressed;
  final String? title;
  final Color? iconsColor;
  final bool showLanguageToggle;
  final bool showDrawerButton;

  const CustomAppBar({
    super.key,
    this.big = false,
    this.onBackPressed,
    this.title,
    this.iconsColor,
    this.showLanguageToggle = false,
    this.showDrawerButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: big ? _buildBigAppBar(context) : _buildSmallAppBar(context),
      ),
    );
  }

  List<Widget> _buildBigAppBar(BuildContext context) {
    return [
      SizedBox(height: MediaQuery.of(context).padding.top),
      if (showLanguageToggle || showDrawerButton)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showDrawerButton)
                IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: Icon(Icons.menu, color: iconsColor ?? Colors.white),
                )
              else
                const SizedBox.shrink(),
              if (showLanguageToggle) const LanguageToggle(),
            ],
          ),
        ),
      if (onBackPressed != null) _buildBackButton(),
      SizedBox(height: 4.h),
      if (title != null) _buildTitle(context, isBig: true),
      SizedBox(height: 8.h),
      const Center(child: LogoRectangle(big: true, heroTag: 'app_logo_big')),
      SizedBox(height: 30.h),
    ];
  }

  List<Widget> _buildSmallAppBar(BuildContext context) {
    return [
      SizedBox(height: MediaQuery.of(context).padding.top),
      Row(
        children: [
          if (showDrawerButton)
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(Icons.menu, color: iconsColor ?? Colors.white),
            ),
          if (onBackPressed != null) _buildBackButton(),
          if (title != null)
            Expanded(child: _buildTitle(context, isBig: false)),
          if (showDrawerButton || onBackPressed != null)
            const SizedBox(width: 48), // Spacer to center the title if there's a leading icon
        ],
      ),
      SizedBox(height: 8.h),
      const Center(child: LogoRectangle(big: false, heroTag: 'app_logo_small')),
      SizedBox(height: 8.h),
    ];
  }

  Widget _buildBackButton() {
    return IconButton(
      onPressed: onBackPressed,
      icon: Icon(Icons.arrow_back, color: iconsColor ?? Colors.white),
    );
  }

  Widget _buildTitle(BuildContext context, {required bool isBig}) {
    return Center(
      child: Text(
        title ?? '',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isBig ? 20.sp : 14.sp,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
