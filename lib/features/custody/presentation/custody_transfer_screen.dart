import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/unified_snackbar.dart';
import '../bloc/custody_transfer/custody_transfer_bloc.dart';
import '../bloc/custody_transfer/custody_transfer_event.dart';
import '../bloc/custody_transfer/custody_transfer_state.dart';
import 'widgets/transfer_form.dart';

class CustodyTransferScreen extends StatelessWidget {
  const CustodyTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return BlocProvider(
      create: (context) => CustodyTransferBloc(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: locale.start_transfer,
          showBackButton: true,
        ),
        body: BlocConsumer<CustodyTransferBloc, CustodyTransferState>(
          listener: (context, state) {
            if (state is CustodyTransferSuccess) {
              UnifiedSnackbar.success(
                context,
                message: locale.transfer_initiated_successfully,
              );
              Navigator.pop(context);
            } else if (state is CustodyTransferError) {
              UnifiedSnackbar.error(context, message: state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is CustodyTransferLoading;

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info card
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primary,
                          size: context.adaptiveIcon(24.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            locale.transfer_info_message,
                            style: TextStyle(
                              fontSize: context.adaptiveFont(14.sp),
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Transfer form
                  TransferForm(
                    onSubmit: (transfer) {
                      context.read<CustodyTransferBloc>().add(
                        CreateCustodyTransfer(transfer),
                      );
                    },
                    isLoading: isLoading,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
