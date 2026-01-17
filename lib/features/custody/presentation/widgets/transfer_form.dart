import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:king_abdulaziz_center_survey_app/core/utils/responsive_layout.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../models/custody_transfer.dart';

class TransferForm extends StatefulWidget {
  final Function(CustodyTransfer) onSubmit;
  final bool isLoading;

  const TransferForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<TransferForm> {
  final _formKey = GlobalKey<FormState>();
  final _toUserEmailController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _toUserEmailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final transfer = CustodyTransfer(
        toUserEmail: _toUserEmailController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      widget.onSubmit(transfer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: _toUserEmailController,
            label: locale.email,
            hintText: locale.enter_email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return locale.please_enter_email;
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return locale.invalid_email;
              }
              return null;
            },
            prefixIcon: Icon(
              Icons.email_outlined,
              color: AppColors.secondaryText,
              size: context.adaptiveIcon(22.sp),
            ),
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: _notesController,
            label: locale.notes,
            hintText: locale.enter_notes_optional,
            keyboardType: TextInputType.multiline,
            prefixIcon: Icon(
              Icons.note_outlined,
              color: AppColors.secondaryText,
              size: context.adaptiveIcon(22.sp),
            ),
          ),
          SizedBox(height: 24.h),
          CustomElevatedButton(
            onPressed: widget.isLoading ? null : _handleSubmit,
            title: locale.start_transfer,
            isLoading: widget.isLoading,
          ),
        ],
      ),
    );
  }
}
