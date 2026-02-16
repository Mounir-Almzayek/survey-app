import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../../core/styles/app_colors.dart';
import '../../../../../core/models/survey/survey_model.dart';
import '../../../../../core/utils/responsive_layout.dart';
import 'survey_analysis_card.dart';

class SurveyPerformanceCarousel extends StatefulWidget {
  final List<Survey> surveys;

  const SurveyPerformanceCarousel({super.key, required this.surveys});

  @override
  State<SurveyPerformanceCarousel> createState() =>
      _SurveyPerformanceCarouselState();
}

class _SurveyPerformanceCarouselState extends State<SurveyPerformanceCarousel> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.surveys.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: context.responsive(350.h, tablet: 350.h, desktop: 350.h),
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.surveys.length,
            itemBuilder: (context, index) {
              return SurveyAnalysisCard(survey: widget.surveys[index]);
            },
          ),
        ),
        if (widget.surveys.length > 1) ...[
          SizedBox(height: 16.h),
          SmoothPageIndicator(
            controller: _pageController,
            count: widget.surveys.length,
            effect: ExpandingDotsEffect(
              activeDotColor: AppColors.primary,
              dotColor: AppColors.muted,
              dotHeight: 8.h,
              dotWidth: 8.w,
              expansionFactor: 3,
            ),
          ),
        ],
      ],
    );
  }
}
