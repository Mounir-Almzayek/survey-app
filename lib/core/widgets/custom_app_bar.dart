import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../styles/app_colors.dart';
import 'logo_rectangle.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showDrawerButton;
  final bool showBackButton;
  final List<Widget>? actions;
  final bool centerTitle;
  final VoidCallback? onDrawerPressed;

  const CustomAppBar({
    super.key,
    this.title,
    this.showDrawerButton = false,
    this.showBackButton = false,
    this.actions,
    this.centerTitle = true,
    this.onDrawerPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: centerTitle,
        leading: _buildLeading(context),
        title: title != null
            ? Text(
                title!,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              )
            : const LogoRectangle(big: false, isFlat: true),
        actions: actions ?? [],
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (showDrawerButton) {
      return IconButton(
        icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
        onPressed: onDrawerPressed ?? () => Scaffold.of(context).openDrawer(),
      );
    }
    if (showBackButton) {
      return IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.primary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      );
    }
    return null;
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}
