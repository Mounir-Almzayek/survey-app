import 'package:flutter/material.dart';

import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';

/// Loading scaffold shown while the start request is in flight or the next
/// section hasn't arrived yet.
class AnsweringLoadingView extends StatelessWidget {
  final String surveyTitle;
  final String? message;

  const AnsweringLoadingView({
    super.key,
    required this.surveyTitle,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          surveyTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(child: LoadingWidget(message: message)),
    );
  }
}
