import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/models/survey/survey_model.dart';
import '../../../public_links/bloc/create_short_lived_link/create_short_lived_link_bloc.dart';
import '../../../public_links/bloc/create_short_lived_link/create_short_lived_link_event.dart';
import '../../../public_links/bloc/create_short_lived_link/create_short_lived_link_state.dart';
import '../../../public_links/presentation/widgets/link_ready_dialog.dart';

/// Starts link creation when opened; shows loading/errors or result (no duration UI).
class ShortLinkConfigDialog extends StatefulWidget {
  final Survey survey;

  const ShortLinkConfigDialog({super.key, required this.survey});

  @override
  State<ShortLinkConfigDialog> createState() => _ShortLinkConfigDialogState();
}

class _ShortLinkConfigDialogState extends State<ShortLinkConfigDialog> {
  /// False until first frame; avoids an empty body while bloc may still hold a prior [ShortLivedLinkReady].
  bool _afterFirstFrame = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _afterFirstFrame = true);
      final bloc = context.read<CreateShortLivedLinkBloc>();
      bloc.add(InitializeShortLinkRequestFromSurvey(widget.survey));
      bloc.add(const CreateShortLivedLinkRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocListener<CreateShortLivedLinkBloc, CreateShortLivedLinkState>(
      listener: (context, state) {
        if (state is ShortLivedLinkReady) {
          Navigator.of(context).pop(context);
          showDialog(
            context: context,
            builder: (ctx) => ShortLinkResultDialog(
              fullUrl: state.fullUrl,
              surveyTitle: widget.survey.title ?? s.short_link,
            ),
          );
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          s.short_link,
          style: TextStyle(
            fontSize: context.adaptiveFont(16.sp),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        content: SizedBox(
          width: context.responsive(280.w, tablet: 320.w, desktop: 360.w),
          child: BlocBuilder<CreateShortLivedLinkBloc, CreateShortLivedLinkState>(
            builder: (context, state) {
              final error = state is ShortLivedLinkError ? state.message : null;
              final showSpinner = error == null &&
                  (!_afterFirstFrame ||
                      state is ShortLivedLinkLoading ||
                      state is ShortLivedLinkInitial);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showSpinner) ...[
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: context.adaptiveIcon(32.sp),
                            height: context.adaptiveIcon(32.sp),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            s.creating_link,
                            style: TextStyle(
                              fontSize: context.adaptiveFont(12.sp),
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (error != null) ...[
                    Text(
                      error,
                      style: TextStyle(
                        fontSize: context.adaptiveFont(11.sp),
                        color: AppColors.error,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    CustomElevatedButton(
                      fontSize: context.adaptiveFont(13.sp),
                      onPressed: () {
                        context.read<CreateShortLivedLinkBloc>().add(
                              InitializeShortLinkRequestFromSurvey(
                                widget.survey,
                              ),
                            );
                        context.read<CreateShortLivedLinkBloc>().add(
                              const CreateShortLivedLinkRequested(),
                            );
                      },
                      title: s.retry,
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(context),
            child: Text(
              s.close,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
