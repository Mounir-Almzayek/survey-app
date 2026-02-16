import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/styles/app_colors.dart';
import '../../../../../../core/utils/responsive_layout.dart';

class ChartContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const ChartContainer({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final padding = context.responsive(16.r, tablet: 18.r, desktop: 20.0);
    final radius = context.responsive(20.r, tablet: 22.r, desktop: 24.0);
    final titleSize = context.responsive(
      13.sp,
      tablet: 14.sp,
      desktop: 15.0,
    );
    final iconSize = context.responsive(
      16.sp,
      tablet: 18.sp,
      desktop: 20.0,
    );
    final gap = context.responsive(16.0, tablet: 18.0, desktop: 20.0);
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: iconSize),
              SizedBox(width: context.responsive(8.0, desktop: 10.0)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: gap),
          child,
        ],
      ),
    );
  }
}
