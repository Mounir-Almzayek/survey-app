import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/models/fingerprint.dart';

class DeviceInfoSection extends StatefulWidget {
  final Fingerprint fingerprint;

  const DeviceInfoSection({super.key, required this.fingerprint});

  @override
  State<DeviceInfoSection> createState() => _DeviceInfoSectionState();
}

class _DeviceInfoSectionState extends State<DeviceInfoSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final f = widget.fingerprint;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.brightWhite,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Header Toggle
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(24.r),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.settings_suggest_outlined,
                      color: AppColors.accent,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locale.device_information,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                        Text(
                          _isExpanded
                              ? "Tap to collapse"
                              : "Tap to show details",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: _isExpanded ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collapsable Content
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
              child: Column(
                children: [
                  const Divider(),
                  SizedBox(height: 12.h),
                  _buildGridItem(Icons.web, locale.browser, f.browser),
                  _buildGridItem(Icons.laptop, locale.operating_system, f.os),
                  _buildGridItem(
                    Icons.smartphone,
                    locale.device_type,
                    f.deviceType,
                  ),
                  _buildGridItem(
                    Icons.aspect_ratio,
                    locale.screen_resolution,
                    "${f.screenWidth}x${f.screenHeight}",
                  ),
                  _buildGridItem(
                    Icons.memory,
                    locale.ram,
                    f.ramGB > 0 ? "${f.ramGB} GB" : "N/A",
                  ),
                  _buildGridItem(
                    Icons.speed,
                    locale.processor_cores,
                    f.processorCores > 0 ? f.processorCores.toString() : "N/A",
                    isLast: true,
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

  Widget _buildGridItem(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.secondaryText),
          SizedBox(width: 12.w),
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: AppColors.secondaryText),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
