import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../assets/assets.dart';

class LogoRectangle extends StatelessWidget {
  final bool big;
  final String? heroTag;
  final bool isFlat;
  final double? width;
  final double? height;

  const LogoRectangle({
    super.key,
    this.big = true,
    this.heroTag,
    this.isFlat = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final tag =
        heroTag ??
        'app_logo_${ModalRoute.of(context)?.settings.name ?? 'default'}';

    return Hero(
      tag: tag,
      child: Container(
        width: width ?? (big ? 260.w : 100.w),
        height: height ?? (big ? 100.h : 50.h),
        decoration: isFlat
            ? null
            : BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
        padding: EdgeInsets.all(isFlat ? 0 : (big ? 16.w : 8.w)),
        child: Center(
          child: Image.asset(
            big ? Assets.logo1 : Assets.logo,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
