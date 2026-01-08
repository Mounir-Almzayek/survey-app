import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../styles/app_colors.dart';

class CustomRadioGroupField<T> extends StatelessWidget {
  final String label;
  final T? selectedValue;
  final List<T> items;
  final String Function(T) getLabel;
  final void Function(T?) onChanged;
  final bool isRequired;

  const CustomRadioGroupField({
    super.key,
    required this.label,
    required this.items,
    required this.getLabel,
    required this.onChanged,
    this.selectedValue,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = isRequired ? '$label *' : label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            effectiveLabel,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Column(
          children: items.map((item) {
            final isSelected = selectedValue == item;
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
                color: isSelected
                    ? AppColors.primary.withOpacity(0.05)
                    : Colors.white,
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  listTileTheme: const ListTileThemeData(horizontalTitleGap: 0),
                ),
                child: RadioListTile<T>(
                  value: item,
                  groupValue: selectedValue,
                  activeColor: AppColors.primary,
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 0,
                  ),
                  title: Text(
                    getLabel(item),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primaryText,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  onChanged: onChanged,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
