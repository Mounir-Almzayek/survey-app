import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../styles/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? label;
  final String? hintText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final bool isPassword;
  final bool obscureText;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    this.validator,
    this.label,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.isPassword = false,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _currentObscure;

  @override
  void initState() {
    super.initState();
    _currentObscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              widget.label!,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          enabled: widget.enabled,
          obscureText: widget.isPassword ? _currentObscure : false,
          onChanged: widget.onChanged,
          style: TextStyle(
            fontSize: 15.sp,
            color: AppColors.primaryText,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _currentObscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.mutedForeground,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentObscure = !_currentObscure;
                      });
                    },
                  )
                : widget.suffixIcon,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            fillColor: widget.enabled ? Colors.white : AppColors.muted,
          ),
        ),
      ],
    );
  }
}
