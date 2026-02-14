import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/models/survey/survey_model.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import 'short_lived_link_section.dart';

/// Section in assignment card for creating a short-lived link, styled like PublicLinksSection.
class ShortLinksSection extends StatelessWidget {
  final Survey survey;

  const ShortLinksSection({super.key, required this.survey});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.isDesktop ? 12.0 : 8.w,
              vertical: context.isDesktop ? 12.0 : 8.h,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.isDesktop ? 10.0 : 8.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.link_rounded,
                    color: AppColors.primary,
                    size: context.adaptiveIcon(18.sp),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    s.short_links,
                    style: TextStyle(
                      fontSize: context.adaptiveFont(14.sp),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 16.r),
            child: ShortLivedLinkSection(
              survey: survey,
              showSectionTitle: false,
            ),
          ),
        ],
      ),
    );
  }
}
