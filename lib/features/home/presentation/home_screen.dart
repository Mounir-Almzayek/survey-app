import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../public_links/presentation/widgets/active_responses_section.dart';
import '../../public_links/presentation/widgets/public_link_code_input_card.dart';
import '../../public_links/presentation/widgets/public_links_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16.r : 24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.welcome_back_researcher,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              s.home_survey_status_subtitle,
              style: TextStyle(fontSize: 14.sp, color: AppColors.secondaryText),
            ),
            SizedBox(height: 10.h),

            // Active Responses (Drafts) Section
            const ActiveResponsesSection(),

            SizedBox(height: 24.h),

            // Public Links Section
            const PublicLinksSection(),

            SizedBox(height: 24.h),

            // Code Input Section
            PublicLinkCodeInputCard(
              onSubmit: (code) {
                // To be implemented later
              },
            ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }
}
