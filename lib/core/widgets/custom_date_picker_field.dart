import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../styles/app_colors.dart';
import '../l10n/generated/l10n.dart';
import '../utils/responsive_layout.dart';

class CustomDatePickerField extends StatelessWidget {
  final String label;
  final String? selectedDate;
  final Function(String) onDateSelected;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool isRequired;
  final bool pickTime;
  final bool onlyTime;

  const CustomDatePickerField({
    super.key,
    required this.label,
    required this.onDateSelected,
    this.selectedDate,
    this.minDate,
    this.maxDate,
    this.isRequired = false,
    this.pickTime = false,
    this.onlyTime = false,
  });

  String _formatDisplayDate(BuildContext context) {
    if (selectedDate == null || selectedDate!.isEmpty) {
      return S.of(context).select_date;
    }

    try {
      final locale = Localizations.localeOf(context).languageCode;
      DateTime? dt;
      
      if (onlyTime) {
        dt = DateTime.tryParse("1970-01-01 $selectedDate");
      } else {
        dt = DateTime.tryParse(selectedDate!);
      }

      if (dt == null) return selectedDate!;

      if (onlyTime) {
        return DateFormat.jm(locale).format(dt);
      } else if (pickTime) {
        return DateFormat.yMd(locale).add_jm().format(dt);
      } else {
        return DateFormat.yMd(locale).format(dt);
      }
    } catch (_) {
      return selectedDate!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            label,
            style: TextStyle(
              fontSize: context.adaptiveFont(13.sp),
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: context.responsive(12.h, tablet: 14.h, desktop: 16.h),
            ),
            decoration: BoxDecoration(
              color: AppColors.brightWhite,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDisplayDate(context),
                    style: TextStyle(
                      fontSize: context.adaptiveFont(14.sp),
                      color: selectedDate?.isNotEmpty == true
                          ? AppColors.primaryText
                          : AppColors.mutedForeground,
                    ),
                  ),
                ),
                Icon(
                  onlyTime
                      ? Icons.access_time_rounded
                      : Icons.calendar_today_rounded,
                  size: context.adaptiveIcon(18.sp),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime firstDate = minDate ?? DateTime(1900);
    DateTime lastDate = maxDate ?? DateTime(2100);

    if (firstDate.isAfter(lastDate)) {
      lastDate = firstDate;
    }

    DateTime initialDate;
    final parsed = (selectedDate != null && selectedDate!.isNotEmpty)
        ? DateTime.tryParse(selectedDate!)
        : null;
    if (parsed != null) {
      if (parsed.isBefore(firstDate)) {
        initialDate = firstDate;
      } else if (parsed.isAfter(lastDate)) {
        initialDate = lastDate;
      } else {
        initialDate = parsed;
      }
    } else {
      final now = DateTime.now();
      if (now.isBefore(firstDate)) {
        initialDate = firstDate;
      } else if (now.isAfter(lastDate)) {
        initialDate = lastDate;
      } else {
        initialDate = now;
      }
    }

    DateTime? pickedDate;
    if (!onlyTime) {
      pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: AppColors.brightWhite,
                surface: AppColors.brightWhite,
                onSurface: AppColors.primaryText,
              ),
              textTheme: Theme.of(context).textTheme,
            ),
            child: child!,
          );
        },
      );
      if (pickedDate == null) return;
    } else {
      pickedDate = DateTime.now();
    }

    if (context.mounted) {
      DateTime finalDateTime = pickedDate;
      if (pickTime || onlyTime) {
        TimeOfDay initialTime = TimeOfDay.fromDateTime(DateTime.now());
        if (selectedDate != null && selectedDate!.isNotEmpty) {
          try {
            if (onlyTime) {
              final parts = selectedDate!.split(':');
              initialTime = TimeOfDay(
                hour: int.parse(parts[0]),
                minute: int.parse(parts[1]),
              );
            } else if (pickTime) {
              final dt = DateTime.tryParse(selectedDate!);
              if (dt != null) {
                initialTime = TimeOfDay.fromDateTime(dt);
              }
            }
          } catch (_) {
            // Fallback to now
          }
        }

        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: initialTime,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: AppColors.brightWhite,
                  surface: AppColors.brightWhite,
                  onSurface: AppColors.primaryText,
                ),
                textTheme: Theme.of(context).textTheme,
              ),
              child: child!,
            );
          },
        );
        if (pickedTime != null) {
          finalDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        } else if (onlyTime) {
          return; // Cancelled time picking for onlyTime
        }
      }

      if (context.mounted) {
        String two(int v) => v.toString().padLeft(2, '0');
        String formatted;
        if (onlyTime) {
          formatted = '${two(finalDateTime.hour)}:${two(finalDateTime.minute)}:00';
        } else if (pickTime) {
          formatted =
              '${finalDateTime.year}-${two(finalDateTime.month)}-${two(finalDateTime.day)} ${two(finalDateTime.hour)}:${two(finalDateTime.minute)}:00';
        } else {
          formatted =
              '${finalDateTime.year}-${two(finalDateTime.month)}-${two(finalDateTime.day)}';
        }
        onDateSelected(formatted);
      }
    }
  }
}
