import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../bloc/get_my_public_links/get_my_public_links_bloc.dart';
import '../../bloc/get_my_public_links/get_my_public_links_event.dart';
import '../../bloc/get_my_public_links/get_my_public_links_state.dart';
import 'public_link_card.dart';

class PublicLinksSection extends StatefulWidget {
  const PublicLinksSection({super.key});

  @override
  State<PublicLinksSection> createState() => _PublicLinksSectionState();
}

class _PublicLinksSectionState extends State<PublicLinksSection> {
  bool _isExpanded = false;

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
        children: [
          // Header - Always visible
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.isDesktop ? 12.0 : 8.w,
              vertical: context.isDesktop ? 12.0 : 8.h,
            ),
            child: Row(
              children: [
                // Expandable Area
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.all(context.isDesktop ? 12.0 : 8.r),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.public_links,
                                  style: TextStyle(
                                    fontSize: context.adaptiveFont(14.sp),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                BlocBuilder<GetMyPublicLinksBloc,
                                    GetMyPublicLinksState>(
                                  builder: (context, state) {
                                    if (state is GetMyPublicLinksSuccess) {
                                      return Text(
                                        s.active_links_count(
                                          state.links.length,
                                        ),
                                        style: TextStyle(
                                          fontSize: context.adaptiveFont(10.sp),
                                          color: AppColors.secondaryText,
                                        ),
                                      );
                                    }
                                    return Text(
                                      s.tap_to_view,
                                      style: TextStyle(
                                        fontSize: context.adaptiveFont(10.sp),
                                        color: AppColors.secondaryText,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.secondaryText,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Vertical Divider
                Container(
                  height: 32,
                  width: 1,
                  color: AppColors.border.withValues(alpha: 0.5),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),

                // Independent Sync Button - Always accessible
                IconButton(
                  onPressed: () {
                    context.read<GetMyPublicLinksBloc>().add(
                      const GetMyPublicLinks(),
                    );
                  },
                  tooltip: s.sync,
                  icon: Icon(
                    Icons.sync_rounded,
                    size: context.adaptiveIcon(18.sp),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Collapsible Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r),
              child: Column(
                children: [
                  const Divider(),
                  SizedBox(height: 12.h),
                  BlocBuilder<GetMyPublicLinksBloc, GetMyPublicLinksState>(
                    builder: (context, state) {
                      if (state is GetMyPublicLinksLoading) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: const LoadingWidget(),
                        );
                      }

                      if (state is GetMyPublicLinksError) {
                        return ErrorStateWidget(
                          message: state.message,
                          onRetry: () {
                            context.read<GetMyPublicLinksBloc>().add(
                              const GetMyPublicLinks(),
                            );
                          },
                        );
                      }

                      if (state is GetMyPublicLinksSuccess) {
                        if (state.links.isEmpty) {
                          return _buildEmptyState(s);
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.links.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            return PublicLinkCard(
                              publicLink: state.links[index],
                              onTap: () {
                                // Handle tap
                              },
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(S s) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        children: [
          Icon(
            Icons.link_off_rounded,
            size: context.adaptiveIcon(40.sp),
            color: AppColors.secondaryText.withValues(alpha: 0.5),
          ),
          SizedBox(height: 8.h),
          Text(
            s.no_public_links,
            style: TextStyle(
              fontSize: context.adaptiveFont(12.sp),
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
