import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../l10n/generated/l10n.dart';
import '../styles/app_colors.dart';
import '../../data/network/api_config.dart';

class CustomImagePicker extends StatelessWidget {
  final String title;
  final XFile? selectedImage;
  final String? existingImageUrl;
  final Function(XFile?) onImagePicked;
  final bool isRequired;
  final bool isBusy;

  const CustomImagePicker({
    super.key,
    required this.title,
    required this.onImagePicked,
    this.selectedImage,
    this.existingImageUrl,
    this.isRequired = false,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final hasImage =
        selectedImage != null || (existingImageUrl?.isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        AbsorbPointer(
          absorbing: isBusy,
          child: GestureDetector(
            onTap: () => _showImageSourceDialog(context),
            child: Stack(
              children: [
                Container(
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: AppColors.muted,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: hasImage
                      ? _buildImagePreview(context)
                      : _buildPlaceholder(locale, context),
                ),
                if (isBusy)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: selectedImage != null
              ? Image.file(
                  File(selectedImage!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : Image.network(
                  APIConfig.getFullImageUrl(existingImageUrl!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image_rounded, size: 40),
                  ),
                ),
        ),
        Positioned(
          top: 8.h,
          right: 8.w,
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.edit_rounded, color: Colors.white, size: 20.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(S locale, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_rounded,
          size: 48.sp,
          color: AppColors.mutedForeground,
        ),
        SizedBox(height: 8.h),
        Text(
          locale.upload_image,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            color: AppColors.mutedForeground,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _showImageSourceDialog(BuildContext context) async {
    final locale = S.of(context);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Wrap(
            children: [
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded,
                      color: AppColors.primary),
                ),
                title: Text(
                  locale.gallery,
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_camera_rounded,
                      color: AppColors.primary),
                ),
                title: Text(
                  locale.camera,
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.camera);
                },
              ),
              if (selectedImage != null || existingImageUrl != null)
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.delete_rounded, color: AppColors.error),
                  ),
                  title: Text(
                    locale.delete,
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onImagePicked(null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null && context.mounted) {
      final croppedImage = await _cropImage(context, image);
      if (croppedImage != null && context.mounted) {
        onImagePicked(croppedImage);
      }
    }
  }

  Future<XFile?> _cropImage(BuildContext context, XFile image) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: S.of(context).edit,
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: S.of(context).edit),
        ],
      );

      if (croppedFile != null) {
        return XFile(croppedFile.path);
      }
      return image;
    } catch (e) {
      return image;
    }
  }
}
