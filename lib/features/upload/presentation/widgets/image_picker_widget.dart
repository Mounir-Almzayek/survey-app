import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:image_picker/image_picker.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/unified_snackbar.dart';
import '../../bloc/upload/upload_bloc.dart';
import '../../bloc/upload/upload_event.dart';
import '../../bloc/upload/upload_state.dart';
import '../../models/upload_file.dart';

/// Widget for picking and uploading images
class ImagePickerWidget extends StatelessWidget {
  final String? title;
  final Function(String? url)? onImageUploaded;
  final bool autoUpload;
  final int? maxWidth;
  final int? maxHeight;
  final int imageQuality;
  final bool allowMultiple;

  const ImagePickerWidget({
    super.key,
    this.title,
    this.onImageUploaded,
    this.autoUpload = true,
    this.maxWidth,
    this.maxHeight,
    this.imageQuality = 85,
    this.allowMultiple = false,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return BlocProvider(
      create: (context) => UploadBloc(),
      child: BlocConsumer<UploadBloc, UploadState>(
        listener: (context, state) {
          if (state is UploadCompleted) {
            onImageUploaded?.call(state.uploadedUrl);
          } else if (state is UploadFailed) {
            UnifiedSnackbar.error(context, message: locale.upload_failed);
          } else if (state is UploadError) {
            UnifiedSnackbar.error(context, message: state.message);
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    title!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
              ],
              _buildImagePickerContent(context, state, locale),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImagePickerContent(
    BuildContext context,
    UploadState state,
    S locale,
  ) {
    if (state is UploadFilePicked) {
      return _buildImagePreview(context, state.file, locale);
    } else if (state is UploadUploading) {
      return _buildUploadProgress(context, state.progress, locale);
    } else if (state is UploadCompleted) {
      return _buildUploadedImage(context, state.uploadedUrl, locale);
    } else {
      return _buildPlaceholder(context, locale);
    }
  }

  Widget _buildPlaceholder(BuildContext context, S locale) {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(context),
      child: Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_photo_alternate_rounded,
                size: 48.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              locale.upload_image,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '${locale.camera} ${locale.or} ${locale.gallery}',
              style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, UploadFile file, S locale) {
    return Stack(
      children: [
        Container(
          height: 200.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Image.file(
              File(file.file.path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        if (autoUpload)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 12.h),
                    Text(
                      locale.uploading,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Positioned(
          top: 8.h,
          right: 8.w,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: IconButton(
              icon: Icon(Icons.close_rounded, color: Colors.white, size: 20.sp),
              onPressed: () {
                context.read<UploadBloc>().add(const ClearUploadsEvent());
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadProgress(
    BuildContext context,
    dynamic progress,
    S locale,
  ) {
    final progressValue = progress.progress;

    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryStart.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60.w,
            height: 60.w,
            child: CircularProgressIndicator(
              value: progressValue,
              strokeWidth: 4,
              color: AppColors.primary,
              backgroundColor: AppColors.muted,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            '${(progressValue * 100).toInt()}%',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            locale.uploading,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedImage(BuildContext context, String url, S locale) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.success, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
                  Center(child: Icon(Icons.broken_image_rounded, size: 40)),
            ),
          ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
          Positioned(
            bottom: 8.h,
            left: 8.w,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                locale.uploaded,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  locale.gallery,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (!context.mounted) return;

                  final bloc = context.read<UploadBloc>();
                  bloc.add(
                    PickImageEvent(
                      source: ImageSource.gallery,
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                      imageQuality: imageQuality,
                    ),
                  );

                  if (autoUpload) {
                    // Auto upload after picking
                    bloc.stream.listen((state) {
                      if (state is UploadFilePicked) {
                        bloc.add(UploadImageEvent(file: state.file));
                      }
                    });
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_camera_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  locale.camera,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (!context.mounted) return;

                  final bloc = context.read<UploadBloc>();
                  bloc.add(
                    PickImageEvent(
                      source: ImageSource.camera,
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                      imageQuality: imageQuality,
                    ),
                  );

                  if (autoUpload) {
                    bloc.stream.listen((state) {
                      if (state is UploadFilePicked) {
                        bloc.add(UploadImageEvent(file: state.file));
                      }
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
