import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/survey/question_model.dart';
import '../../styles/app_colors.dart';
import '../../../features/upload/models/upload_file.dart';
import '../../../features/upload/repository/upload_online_repository.dart';
import 'survey_question_card.dart';

typedef FileUploader = Future<String> Function(XFile file);
typedef FilePickerFn = Future<XFile?> Function(BuildContext context);

/// File upload field that uploads immediately on selection and stores the
/// server path as the answer value.
class SurveyFileField extends StatefulWidget {
  final Question question;
  final String? value; // server path
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isEditable;
  final FileUploader? uploader; // injection for tests
  final FilePickerFn? picker;   // injection for tests

  const SurveyFileField({
    super.key,
    required this.question,
    required this.onChanged,
    this.value,
    this.errorText,
    this.isVisible = true,
    this.isEditable = true,
    this.uploader,
    this.picker,
  });

  @override
  State<SurveyFileField> createState() => _SurveyFileFieldState();
}

class _SurveyFileFieldState extends State<SurveyFileField> {
  XFile? _localPreview;
  bool _isUploading = false;
  String? _errorMessage;

  Future<void> _pickAndUpload() async {
    final pick = widget.picker ?? _defaultPicker;
    final file = await pick(context);
    if (file == null) return;
    await _upload(file);
  }

  Future<void> _upload(XFile file) async {
    setState(() {
      _localPreview = file;
      _isUploading = true;
      _errorMessage = null;
    });
    try {
      final upload = widget.uploader ?? _defaultUploader;
      final path = await upload(file);
      if (!mounted) return;
      widget.onChanged(path);
      setState(() => _isUploading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _errorMessage = e.toString();
      });
    }
  }

  static Future<String> _defaultUploader(XFile file) =>
      UploadOnlineRepository.uploadImage(
          file: UploadFile.fromXFile(file));

  static Future<XFile?> _defaultPicker(BuildContext context) =>
      ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

  Widget _preview() {
    if (_localPreview != null) {
      return Image.file(File(_localPreview!.path),
          height: 140.h, fit: BoxFit.cover);
    }
    if (widget.value != null && widget.value!.isNotEmpty) {
      return Icon(Icons.check_circle, color: AppColors.primary, size: 40.sp);
    }
    return Icon(Icons.add_photo_alternate_rounded,
        color: AppColors.mutedForeground, size: 40.sp);
  }

  @override
  Widget build(BuildContext context) {
    return SurveyQuestionCard(
      label: widget.question.label,
      helpText: widget.question.helpText,
      isRequired: widget.question.isRequired,
      errorText: widget.errorText ?? _errorMessage,
      isVisible: widget.isVisible,
      validations: widget.question.questionValidations,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                key: const ValueKey('file-pick-button'),
                onTap: widget.isEditable && !_isUploading
                    ? _pickAndUpload
                    : null,
                child: Container(
                  height: 140.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.muted,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(child: _preview()),
                ),
              ),
              if (_isUploading)
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black26),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
          if (_errorMessage != null) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: Text(_errorMessage!,
                      style: TextStyle(
                          color: AppColors.destructive, fontSize: 11.sp)),
                ),
                TextButton(
                  key: const ValueKey('file-retry-button'),
                  onPressed: _localPreview == null
                      ? null
                      : () => _upload(_localPreview!),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
