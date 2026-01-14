import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final _deviceIdController = TextEditingController();
  final _toUserIdController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _deviceIdController.dispose();
    _toUserIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final transfer = CustodyTransfer(
        physicalDeviceId: int.parse(_deviceIdController.text.trim()),
        toUserId: int.parse(_toUserIdController.text.trim()),
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
            controller: _deviceIdController,
            label: "Physical Device ID",
            hintText: "Enter Device ID",
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter device ID";
              }
              if (int.tryParse(value) == null) {
                return "Invalid ID";
              }
              return null;
            },
            prefixIcon: Icon(
              Icons.devices_other_outlined,
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: _toUserIdController,
            label: "To User ID",
            hintText: "Enter Target User ID",
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter user ID";
              }
              if (int.tryParse(value) == null) {
                return "Invalid ID";
              }
              return null;
            },
            prefixIcon: Icon(
              Icons.person_outline_rounded,
              color: AppColors.secondaryText,
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

