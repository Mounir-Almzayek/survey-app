import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_elevated_button.dart';

class PublicLinkCodeInputCard extends StatefulWidget {
  final Function(String code) onSubmit;

  const PublicLinkCodeInputCard({super.key, required this.onSubmit});

  @override
  State<PublicLinkCodeInputCard> createState() =>
      _PublicLinkCodeInputCardState();
}

class _PublicLinkCodeInputCardState extends State<PublicLinkCodeInputCard> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _scanQrCode() async {
    final result = await context.push<String>(
      '${Routes.qrScannerPath}?returnCodeOnly=true',
    );

    if (result != null && mounted) {
      setState(() {
        _codeController.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                s.enter_survey_code,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _codeController,
                  hintText: s.survey_code_placeholder,
                  prefixIcon: Icon(
                    Icons.tag_rounded,
                    color: AppColors.secondaryText,
                    size: 20.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              InkWell(
                onTap: _scanQrCode,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  height: 48.h,
                  width: 48.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.qr_code_2_rounded,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          CustomElevatedButton(
            title: s.submit,
            onPressed: () {
              if (_codeController.text.isNotEmpty) {
                widget.onSubmit(_codeController.text);
              }
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
