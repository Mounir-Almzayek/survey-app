import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/empty_widget.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../bloc/custody_list/custody_list_bloc.dart';
import '../bloc/custody_list/custody_list_event.dart';
import '../bloc/custody_list/custody_list_state.dart';
import '../../../core/widgets/infinite_list_view_widget.dart';
import 'widgets/custody_card.dart';
import 'custody_transfer_screen.dart';
import 'custody_verification_screen.dart';

class CustodyListScreen extends StatefulWidget {
  const CustodyListScreen({super.key});

  @override
  State<CustodyListScreen> createState() => _CustodyListScreenState();
}

class _CustodyListScreenState extends State<CustodyListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 100.h),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CustodyTransferScreen(),
              ),
            );
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            locale.start_transfer,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: BlocConsumer<CustodyListBloc, CustodyListState>(
        listener: (context, state) {
          if (state is CustodyListError) {
            UnifiedSnackbar.error(context, message: state.message);
          }
        },
        builder: (context, state) {
          if (state is CustodyListLoading) {
            return const LoadingWidget();
          }

          if (state is CustodyListError &&
              (state is! CustodyListLoaded ||
                  (state as CustodyListLoaded).records.isEmpty)) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () {
                context.read<CustodyListBloc>().add(
                  const LoadCustodyRecords(forceRefresh: true),
                );
              },
            );
          }

          if (state is CustodyListLoaded) {
            if (state.records.isEmpty) {
              return EmptyWidget(
                title: locale.no_custody_records,
                subtitle: locale.no_custody_records_description,
                icon: Icons.devices_other_outlined,
              );
            }

            return InfiniteListViewWidget(
              scrollController: _scrollController,
              items: state.records,
              isLoading: state.isFetchingMore,
              hasMoreData: state.hasMoreData,
              fetchMoreItems: () async {
                context.read<CustodyListBloc>().add(const LoadNextPage());
              },
              onRefresh: () async {
                context.read<CustodyListBloc>().add(
                  const RefreshCustodyRecords(),
                );
              },
              padding: EdgeInsets.all(16.w),
              itemBuilder: (context, record) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: CustodyCard(
                    record: record,
                    onVerify: record.isPending
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustodyVerificationScreen(
                                  custodyId: record.id,
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
