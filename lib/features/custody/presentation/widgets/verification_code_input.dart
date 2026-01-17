import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/styles/app_colors.dart';

class VerificationCodeInput extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final int length;
  final bool enabled;
  final String? errorText;

  const VerificationCodeInput({
    super.key,
    this.onChanged,
    this.onCompleted,
    this.length = 6,
    this.enabled = true,
    this.errorText,
  });

  @override
  State<VerificationCodeInput> createState() => _VerificationCodeInputState();
}

class _VerificationCodeInputState extends State<VerificationCodeInput> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  final List<String> _values = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.length; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
      _values.add('');
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste
      final pastedValue = value.substring(0, widget.length);
      for (int i = 0; i < pastedValue.length && i < widget.length; i++) {
        _values[i] = pastedValue[i];
        _controllers[i].text = pastedValue[i];
        if (i < widget.length - 1) {
          _focusNodes[i + 1].requestFocus();
        }
      }
    } else {
      _values[index] = value;
    }

    final code = _values.join('');
    widget.onChanged?.call(code);

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.length,
            (index) => _buildInputField(index),
          ),
        ),
        if (widget.errorText != null) ...[
          SizedBox(height: 8.h),
          Text(
            widget.errorText!,
            style: TextStyle(fontSize: context.adaptiveFont(12.sp), color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildInputField(int index) {
    final isLast = index == widget.length - 1;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      width: 48.w,
      height: 56.h,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        enabled: widget.enabled,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: TextStyle(
          fontSize: context.adaptiveFont(24.sp),
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: widget.enabled
              ? AppColors.surface
              : AppColors.muted.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: widget.errorText != null
                  ? AppColors.error
                  : AppColors.border,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: widget.errorText != null
                  ? AppColors.error
                  : AppColors.border,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: widget.errorText != null
                  ? AppColors.error
                  : AppColors.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) => _onChanged(index, value),
        onTap: () {
          _controllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: _controllers[index].text.length),
          );
        },
        onSubmitted: (_) {
          if (!isLast) {
            _focusNodes[index + 1].requestFocus();
          }
        },
        onEditingComplete: () {
          if (!isLast) {
            _focusNodes[index + 1].requestFocus();
          }
        },
      ),
    );
  }
}
