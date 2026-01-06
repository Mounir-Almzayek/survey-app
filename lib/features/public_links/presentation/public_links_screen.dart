import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/empty_widget.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../bloc/load_public_links/load_public_links_bloc.dart';
import '../bloc/load_public_links/load_public_links_event.dart';
import '../bloc/load_public_links/load_public_links_state.dart';
import 'widgets/public_link_card.dart';

class PublicLinksScreen extends StatelessWidget {
  const PublicLinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: locale.public_links,
        showDrawerButton: false,
      ),
      body: BlocConsumer<LoadPublicLinksBloc, LoadPublicLinksState>(
        listener: (context, state) {
          if (state is LoadPublicLinksError) {
            UnifiedSnackbar.error(context, message: state.message);
          }
        },
        builder: (context, state) {
          if (state is LoadPublicLinksLoading) {
            return const LoadingWidget();
          }

          if (state is LoadPublicLinksError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () {
                context.read<LoadPublicLinksBloc>().add(const LoadPublicLinks(forceRefresh: true));
              },
            );
          }

          if (state is LoadPublicLinksLoaded) {
            if (state.links.isEmpty) {
              return EmptyWidget(
                title: locale.no_public_links,
                subtitle: locale.no_public_links_description,
                icon: Icons.link_off_rounded,
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<LoadPublicLinksBloc>().add(const RefreshPublicLinks());
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: state.links.length,
                itemBuilder: (context, index) {
                  final link = state.links[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: PublicLinkCard(link: link),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

