import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/survey/question_model.dart';
import '../custom_image_picker.dart';
import 'survey_question_card.dart';

class SurveyFileField extends StatelessWidget {
  final Question question;
  final XFile? selectedFile;
  final String? existingFileUrl;
  final Function(XFile?) onFilePicked;
  final String? errorText;
  final bool isVisible;
  final bool isBusy;

  const SurveyFileField({
    super.key,
    required this.question,
    required this.onFilePicked,
    this.selectedFile,
    this.existingFileUrl,
    this.errorText,
    this.isVisible = true,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return SurveyQuestionCard(
      label: question.label,
      helpText: question.helpText,
      isRequired: question.isRequired,
      errorText: errorText,
      isVisible: isVisible,
      child: CustomImagePicker(
        title: "", // Handled by SurveyQuestionCard
        onImagePicked: onFilePicked,
        selectedImage: selectedFile,
        existingImageUrl: existingFileUrl,
        isBusy: isBusy,
      ),
    );
  }
}
