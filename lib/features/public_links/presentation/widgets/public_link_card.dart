import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readmore/readmore.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/unified_snackbar.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../data/network/api_config.dart';
import '../../../device_location/service/location_service.dart';
import '../../models/public_link.dart';
import 'link_ready_dialog.dart';

class PublicLinkCard extends StatefulWidget {
  final PublicLink publicLink;
  final VoidCallback? onTap;

  const PublicLinkCard({super.key, required this.publicLink, this.onTap});

  @override
  State<PublicLinkCard> createState() => _PublicLinkCardState();
}

class _PublicLinkCardState extends State<PublicLinkCard> {
  bool _isGenerating = false;

  Future<void> _onGeneratePressed() async {
    final publicLink = widget.publicLink;
    final s = S.of(context);

    setState(() => _isGenerating = true);
    try {
      final locale = publicLink.survey?.lang;
      final String fullUrl;
      if (publicLink.requireLocation) {
        final hasPermission = await LocationService.hasPermissions();
        if (!hasPermission) {
          final granted = await LocationService.requestPermissions();
          if (!granted) {
            if (mounted) {
              UnifiedSnackbar.error(
                context,
                message: s.location_required_for_short_link,
              );
            }
            return;
          }
        }
        final location = await LocationService.getCurrentLocation();
        fullUrl = APIConfig.buildShortLivedSurveyUrl(
          publicLink.shortCode,
          location.latitude,
          location.longitude,
          locale: locale,
        );
      } else {
        fullUrl = APIConfig.buildPublicSurveyUrl(
          publicLink.shortCode,
          locale: locale,
        );
      }

      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => ShortLinkResultDialog(
          fullUrl: fullUrl,
          surveyTitle: publicLink.surveyTitle,
        ),
      );
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        UnifiedSnackbar.error(context, message: msg);
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final publicLink = widget.publicLink;
    final status = publicLink.status;
    final s = S.of(context);
    final canGenerate = publicLink.isActive;

    return Container(
      padding: EdgeInsets.all(
        context.responsive(12.r, tablet: 16.r, desktop: 20.0),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  publicLink.surveyTitle,
                  style: TextStyle(
                    fontSize: context.adaptiveFont(14.sp),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusChip(context, status),
            ],
          ),
          const SizedBox(height: 12),

          if (publicLink.survey?.description != null &&
              publicLink.survey!.description?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ReadMoreText(
                publicLink.survey!.description ?? "",
                trimLines: 2,
                colorClickableText: AppColors.primary,
                trimMode: TrimMode.Line,
                trimCollapsedText: s.read_more,
                trimExpandedText: ' ${s.show_less}',
                style: TextStyle(
                  fontSize: context.adaptiveFont(11.sp),
                  color: AppColors.secondaryText,
                  height: 1.5,
                ),
                moreStyle: TextStyle(
                  fontSize: context.adaptiveFont(11.sp),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                lessStyle: TextStyle(
                  fontSize: context.adaptiveFont(11.sp),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),

          Wrap(
            spacing: context.isDesktop ? 20.0 : 16.w,
            runSpacing: 8.h,
            children: [
              _InfoItem(
                icon: Icons.tag_rounded,
                label: s.code_colon(publicLink.shortCode),
              ),
              _InfoItem(
                icon: Icons.people_outline_rounded,
                label: "${s.max_responses}: ${publicLink.maxResponses}",
              ),
              if (publicLink.expiresAt != null)
                _InfoItem(
                  icon: Icons.event_busy_rounded,
                  label:
                      "${s.expires_at}: ${publicLink.expiresAt!.toLocal().toString().split(' ')[0]}",
                ),
              _InfoItem(
                icon: Icons.location_on_outlined,
                label: publicLink.requireLocation
                    ? s.location_required
                    : s.not_available,
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.3),
              ),
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
                CustomElevatedButton(
                  fontSize: context.adaptiveFont(12.sp),
                  title: s.generate_link,
                  isLoading: _isGenerating,
                  disabled: !canGenerate,
                  onPressed: canGenerate ? _onGeneratePressed : () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, PublicLinkStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: context.adaptiveIcon(10.sp),
            color: status.color,
          ),
          SizedBox(width: 4.w),
          Text(
            status.label.toUpperCase(),
            style: TextStyle(
              fontSize: context.adaptiveFont(8.sp),
              fontWeight: FontWeight.bold,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: context.adaptiveIcon(12.sp),
          color: AppColors.secondaryText,
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: context.adaptiveFont(10.sp),
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}
