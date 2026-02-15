import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readmore/readmore.dart';

import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/styles/app_colors.dart';
import '../../../../../core/utils/responsive_layout.dart';

class DescriptionSection extends StatelessWidget {
  final String? description;

  const DescriptionSection({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final desc = description ?? "";
    if (desc.isEmpty) return const SizedBox.shrink();

    return ReadMoreText(
      desc,
      trimLines: 2,
      colorClickableText: AppColors.primary,
      trimMode: TrimMode.Line,
      trimCollapsedText: s.read_more,
      trimExpandedText: ' ${s.show_less}',
      style: TextStyle(
        fontSize: context.adaptiveFont(12).sp,
        color: AppColors.secondaryText,
      ),
      moreStyle: TextStyle(
        fontSize: context.adaptiveFont(10).sp,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
      lessStyle: TextStyle(
        fontSize: context.adaptiveFont(10).sp,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }
}
