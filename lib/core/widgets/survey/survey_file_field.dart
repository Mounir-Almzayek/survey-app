import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/generated/l10n.dart';
import '../../models/survey/question_model.dart';
import '../../enums/survey_enums.dart';
import '../../styles/app_colors.dart';
import '../../../features/upload/bloc/upload/upload_bloc.dart';
import '../../../features/upload/bloc/upload/upload_event.dart';
import '../../../features/upload/bloc/upload/upload_state.dart';
import '../../../features/upload/models/upload_progress.dart';
import 'survey_question_card.dart';

/// File upload field that uses UploadBloc and stores the
/// server path as the answer value.
class SurveyFileField extends StatelessWidget {
  final Question question;
  final String? value; // server path
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isEditable;

  const SurveyFileField({
    super.key,
    required this.question,
    required this.onChanged,
    this.value,
    this.errorText,
    this.isVisible = true,
    this.isEditable = true,
  });

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: Text(S.of(context).camera),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                context.read<UploadBloc>().add(
                      PickAndUploadImageEvent(
                        questionId: question.id,
                        source: ImageSource.camera,
                      ),
                    );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(S.of(context).gallery),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                context.read<UploadBloc>().add(
                      PickAndUploadImageEvent(
                        questionId: question.id,
                        source: ImageSource.gallery,
                      ),
                    );
              },
            ),
            if (question.type == QuestionType.file)
              ListTile(
                leading: const Icon(Icons.insert_drive_file_rounded),
                title: Text(S.of(context).upload_file),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  context.read<UploadBloc>().add(
                        PickAndUploadFileEvent(questionId: question.id),
                      );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _retry(BuildContext context) {
    context.read<UploadBloc>().add(RetryUploadEvent(questionId: question.id));
  }

  Widget _preview(String? serverPath, UploadProgress? progress) {
    // 1. If we have a local file being uploaded
    if (progress != null && progress.file.file.path.isNotEmpty) {
      if (progress.file.isImage) {
        return Image.file(
          File(progress.file.file.path),
          height: 140.h,
          fit: BoxFit.cover,
        );
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file_rounded, color: AppColors.primary, size: 40.sp),
            SizedBox(height: 8.h),
            Text(
              progress.file.fileName ?? "File",
              style: TextStyle(fontSize: 12.sp, color: AppColors.primary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      }
    }

    // 2. If we have a completed server path
    if (serverPath != null && serverPath.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: AppColors.primary, size: 40.sp),
          SizedBox(height: 8.h),
          Text(
            S.current.upload_success,
            style: TextStyle(fontSize: 12.sp, color: AppColors.primary),
          ),
        ],
      );
    }

    // 3. Default state
    return Icon(
      question.type == QuestionType.file
          ? Icons.upload_file_rounded
          : Icons.add_photo_alternate_rounded,
      color: AppColors.mutedForeground,
      size: 40.sp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UploadBloc, UploadState>(
      listenWhen: (prev, curr) {
        final prevStatus = prev.uploads[question.id]?.status;
        final currStatus = curr.uploads[question.id]?.status;
        return prevStatus != currStatus && currStatus == UploadStatus.completed;
      },
      listener: (context, state) {
        final upload = state.uploads[question.id];
        if (upload?.uploadedUrl != null) {
          onChanged(upload!.uploadedUrl);
        }
      },
      child: BlocBuilder<UploadBloc, UploadState>(
        builder: (context, state) {
          final upload = state.uploads[question.id];
          final isUploading = upload?.status == UploadStatus.uploading;
          final isPicking = state is UploadPicking && state.questionId == question.id;
          final error = upload?.status == UploadStatus.failed ? upload?.error : null;

          return SurveyQuestionCard(
            label: question.label,
            helpText: question.helpText,
            isRequired: question.isRequired,
            errorText: errorText ?? error,
            isVisible: isVisible,
            validations: question.questionValidations,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      key: ValueKey('file-pick-button-${question.id}'),
                      onTap: isEditable && !isUploading && !isPicking
                          ? () => _showPicker(context)
                          : null,
                      child: Container(
                        height: 140.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.muted,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Center(child: _preview(value, upload)),
                      ),
                    ),
                    if (isUploading || isPicking)
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.black26),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 8.h),
                                if (isUploading)
                                  Text(
                                    "${((upload?.progress ?? 0) * 100).toInt()}%",
                                    style: const TextStyle(color: Colors.white),
                                  )
                                else
                                  Text(
                                    S.of(context).processing,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (error != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(
                            color: AppColors.destructive,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _retry(context),
                        child: Text(S.of(context).retry),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}


