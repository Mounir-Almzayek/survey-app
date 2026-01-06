import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/unified_snackbar.dart';
import '../../bloc/upload/upload_bloc.dart';
import '../../bloc/upload/upload_event.dart';
import '../../bloc/upload/upload_state.dart';
import '../../models/upload_file.dart';

/// Widget for picking and uploading files
class FilePickerWidget extends StatelessWidget {
  final String? title;
  final Function(String? url)? onFileUploaded;
  final bool autoUpload;
  final List<String>? allowedExtensions;
  final String? type;

  const FilePickerWidget({
    super.key,
    this.title,
    this.onFileUploaded,
    this.autoUpload = true,
    this.allowedExtensions,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return BlocProvider(
      create: (context) => UploadBloc(),
      child: BlocConsumer<UploadBloc, UploadState>(
        listener: (context, state) {
          if (state is UploadCompleted) {
            onFileUploaded?.call(state.uploadedUrl);
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
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
              ],
              _buildFilePickerContent(context, state, locale),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilePickerContent(
    BuildContext context,
    UploadState state,
    S locale,
  ) {
    if (state is UploadFilePicked) {
      return _buildFilePreview(context, state.file, locale);
    } else if (state is UploadUploading) {
      return _buildUploadProgress(context, state.progress, locale);
    } else if (state is UploadCompleted) {
      return _buildUploadedFile(context, state.uploadedUrl, locale);
    } else {
      return _buildPlaceholder(context, locale);
    }
  }

  Widget _buildPlaceholder(BuildContext context, S locale) {
    return GestureDetector(
      onTap: () {
        final bloc = context.read<UploadBloc>();
        bloc.add(
          PickFileEvent(allowedExtensions: allowedExtensions, type: type),
        );

        if (autoUpload) {
          bloc.stream.listen((state) {
            if (state is UploadFilePicked) {
              bloc.add(UploadFileEvent(file: state.file));
            }
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(24.w),
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
                Icons.attach_file_rounded,
                size: 48.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              locale.select_file,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              locale.upload_file,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(BuildContext context, UploadFile file, S locale) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              _getFileIcon(file),
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName ?? file.file.name,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  _getFileSize(file),
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: AppColors.error,
                size: 20.sp,
              ),
              onPressed: () {
                context.read<UploadBloc>().add(const ClearUploadsEvent());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgress(
    BuildContext context,
    dynamic progress,
    S locale,
  ) {
    final progressValue = progress.progress;

    return Container(
      padding: EdgeInsets.all(16.w),
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
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  _getFileIcon(progress.file),
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress.file.fileName ?? progress.file.file.name,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 6.h,
                        color: AppColors.primary,
                        backgroundColor: AppColors.muted,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          locale.uploading,
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(progressValue * 100).toInt()}%',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedFile(BuildContext context, String url, S locale) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
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
            child: Icon(Icons.check_rounded, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.uploaded,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  locale.upload_success,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(UploadFile file) {
    if (file.isImage) {
      return Icons.image_rounded;
    } else if (file.isDocument) {
      return Icons.description_rounded;
    } else {
      return Icons.insert_drive_file_rounded;
    }
  }

  String _getFileSize(UploadFile file) {
    try {
      final fileSize = File(file.file.path).lengthSync();
      if (fileSize < 1024) {
        return '$fileSize B';
      } else if (fileSize < 1024 * 1024) {
        return '${(fileSize / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'Unknown size';
    }
  }
}
