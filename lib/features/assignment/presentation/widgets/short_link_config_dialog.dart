import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../public_links/bloc/create_short_lived_link/create_short_lived_link_bloc.dart';
import '../../../public_links/bloc/create_short_lived_link/create_short_lived_link_event.dart';
import '../../../public_links/bloc/create_short_lived_link/create_short_lived_link_state.dart';
import '../../../../core/models/survey/survey_model.dart';
import '../../../public_links/presentation/widgets/link_ready_dialog.dart';

/// Dialog to set duration in minutes (default 1 min, from survey model) and generate short link.
class ShortLinkConfigDialog extends StatefulWidget {
  final Survey survey;

  const ShortLinkConfigDialog({super.key, required this.survey});

  @override
  State<ShortLinkConfigDialog> createState() => _ShortLinkConfigDialogState();
}

class _ShortLinkConfigDialogState extends State<ShortLinkConfigDialog> {
  late TextEditingController _minutesController;
  late FocusNode _minutesFocusNode;

  @override
  void initState() {
    super.initState();
    _minutesController = TextEditingController(text: '1');
    _minutesFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CreateShortLivedLinkBloc>().add(
            InitializeShortLinkRequestFromSurvey(widget.survey),
          );
    });
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _minutesFocusNode.dispose();
    super.dispose();
  }

  void _syncControllerFromState(int minutes) {
    final text = minutes.toString();
    if (_minutesController.text != text) {
      _minutesController.text = text;
    }
  }

  void _adjustMinutes(BuildContext context, int delta) {
    final bloc = context.read<CreateShortLivedLinkBloc>();
    final state = bloc.state;
    final current = state.request?.durationMinutes ?? 1;
    final max = state.maxDurationMinutes ?? 525600;
    final next = (current + delta).clamp(1, max);
    bloc.add(UpdateShortLinkRequestDurationMinutes(next));
    _syncControllerFromState(next);
  }

  void _onMinutesSubmitted(BuildContext context, String value) {
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 1) return;
    final bloc = context.read<CreateShortLivedLinkBloc>();
    final max = bloc.state.maxDurationMinutes ?? 525600;
    final clamped = parsed.clamp(1, max);
    bloc.add(UpdateShortLinkRequestDurationMinutes(clamped));
    _syncControllerFromState(clamped);
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
              expiresAt: state.expiresAt,
              validityMinutes: state.request?.durationMinutes,
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
          child: BlocConsumer<CreateShortLivedLinkBloc, CreateShortLivedLinkState>(
            listenWhen: (prev, curr) =>
                prev.request?.durationMinutes != curr.request?.durationMinutes,
            listener: (context, state) {
              final minutes = state.request?.durationMinutes ?? 1;
              _syncControllerFromState(minutes);
            },
            builder: (context, state) {
              final isLoading = state is ShortLivedLinkLoading;
              final error = state is ShortLivedLinkError ? state.message : null;
              final minutes = state.request?.durationMinutes ?? 1;
              final maxMinutes = state.maxDurationMinutes ?? 525600;

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  Text(
                    s.link_validity_duration,
                    style: TextStyle(
                      fontSize: context.adaptiveFont(12.sp),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    s.survey_available_for_duration(minutes),
                    style: TextStyle(
                      fontSize: context.adaptiveFont(11.sp),
                      color: AppColors.secondaryText,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      _DurationStepperButton(
                        icon: Icons.remove,
                        onPressed: isLoading || minutes <= 1
                            ? null
                            : () => _adjustMinutes(context, -1),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: TextField(
                          controller: _minutesController,
                          focusNode: _minutesFocusNode,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          enabled: !isLoading,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: context.adaptiveFont(14.sp),
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                          decoration: InputDecoration(
                            suffixText: s.minutes,
                            suffixStyle: TextStyle(
                              fontSize: context.adaptiveFont(11.sp),
                              color: AppColors.secondaryText,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: AppColors.border.withValues(alpha: 0.6),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: AppColors.border.withValues(alpha: 0.6),
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                          ),
                          onSubmitted: (v) => _onMinutesSubmitted(context, v),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      _DurationStepperButton(
                        icon: Icons.add,
                        onPressed: isLoading || minutes >= maxMinutes
                            ? null
                            : () => _adjustMinutes(context, 1),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  if (isLoading)
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
                    )
                  else
                    CustomElevatedButton(
                      fontSize: context.adaptiveFont(13.sp),
                      onPressed: () {
                        _onMinutesSubmitted(context, _minutesController.text);
                        context.read<CreateShortLivedLinkBloc>().add(
                              const CreateShortLivedLinkRequested(),
                            );
                      },
                      title: s.generate_link,
                    ),
                  if (error != null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      error,
                      style: TextStyle(
                        fontSize: context.adaptiveFont(11.sp),
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
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

class _DurationStepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _DurationStepperButton({
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed != null
          ? AppColors.primary.withValues(alpha: 0.12)
          : AppColors.background,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 44.w,
          height: 44.h,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: context.adaptiveIcon(22.sp),
            color: onPressed != null ? AppColors.primary : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}
