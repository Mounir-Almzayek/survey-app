import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/unified_snackbar.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../public_links/bloc/create_short_lived_link/create_short_lived_link_bloc.dart';
import '../../../public_links/bloc/create_short_lived_link/create_short_lived_link_state.dart';
import '../../../public_links/presentation/widgets/qr_code_dialog.dart';
import '../../../../core/models/survey/survey_model.dart';
import 'short_link_config_dialog.dart';

/// Section inside assignment card to create and display a short-lived link
/// with current GPS appended. Same visual style as the link box in PublicLinkCard.
class ShortLivedLinkSection extends StatelessWidget {
  final Survey survey;
  final bool showSectionTitle;

  const ShortLivedLinkSection({
    super.key,
    required this.survey,
    this.showSectionTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateShortLivedLinkBloc(),
      child: _ShortLivedLinkContent(
        survey: survey,
        showSectionTitle: showSectionTitle,
      ),
    );
  }
}

class _ShortLivedLinkContent extends StatelessWidget {
  final Survey survey;
  final bool showSectionTitle;

  const _ShortLivedLinkContent({
    required this.survey,
    this.showSectionTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<CreateShortLivedLinkBloc, CreateShortLivedLinkState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showSectionTitle) ...[
              const SizedBox(height: 16),
              Text(
                s.short_lived_link_section,
                style: TextStyle(
                  fontSize: context.adaptiveFont(12.sp),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (state is ShortLivedLinkInitial ||
                state is ShortLivedLinkError) ...[
              if (state is ShortLivedLinkError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    state.message,
                    style: TextStyle(
                      fontSize: context.adaptiveFont(11.sp),
                      color: AppColors.error,
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                  fontSize: context.adaptiveFont(12.sp),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => BlocProvider.value(
                        value: context.read<CreateShortLivedLinkBloc>(),
                        child: ShortLinkConfigDialog(survey: survey),
                      ),
                    );
                  },
                  title: s.create_short_link,
                ),
              ),
            ] else if (state is ShortLivedLinkLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SizedBox(
                    width: context.adaptiveIcon(24.sp),
                    height: context.adaptiveIcon(24.sp),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (state is ShortLivedLinkReady)
              _buildLinkBox(
                context,
                fullUrl: state.fullUrl,
                surveyTitle: survey.title ?? '',
                s: s,
              ),
          ],
        );
      },
    );
  }

  Widget _buildLinkBox(
    BuildContext context, {
    required String fullUrl,
    required String surveyTitle,
    required S s,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.survey_link,
            style: TextStyle(
              fontSize: context.adaptiveFont(9.sp),
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _launchUrl(context, fullUrl),
                  child: Text(
                    fullUrl,
                    style: TextStyle(
                      fontSize: context.adaptiveFont(11.sp),
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.copy_rounded,
                onTap: () => _copyToClipboard(context, fullUrl, s),
                tooltip: s.copy_link,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.qr_code_2_rounded,
                onTap: () => _showQRCode(context, fullUrl, surveyTitle),
                tooltip: s.show_qr_code,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        UnifiedSnackbar.error(
          context,
          message: 'Could not launch URL: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String url, S s) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      UnifiedSnackbar.success(context, message: s.link_copied);
    }
  }

  void _showQRCode(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (context) => QRCodeDialog(
        url: url,
        surveyTitle: title.isEmpty
            ? S.of(context).short_lived_link_section
            : title,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: context.adaptiveIcon(16.sp),
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
