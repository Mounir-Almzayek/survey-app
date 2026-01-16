import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/survey/question_model.dart';
import '../custom_image_picker.dart';
import 'survey_question_card.dart';

class SurveyFileField extends StatelessWidget {
  final Question question;
  final XFile? value;
  final String? existingFileUrl;
  final ValueChanged<XFile?> onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isBusy;
  final bool isEditable;

  const SurveyFileField({
    super.key,
    required this.question,
    required this.onChanged,
    this.value,
    this.existingFileUrl,
    this.errorText,
    this.isVisible = true,
    this.isBusy = false,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    return SurveyQuestionCard(
      label: question.label,
      helpText: question.helpText,
      isRequired: question.isRequired,
      errorText: errorText,
      isVisible: isVisible,
      validations: question.questionValidations,
      child: AbsorbPointer(
        absorbing: !isEditable,
        child: Opacity(
          opacity: isEditable ? 1.0 : 0.6,
          child: CustomImagePicker(
            title: "", // Handled by SurveyQuestionCard
            onImagePicked: isEditable ? onChanged : (_) {},
            selectedImage: value,
            existingImageUrl: existingFileUrl,
            isBusy: isBusy,
          ),
        ),
      ),
    );
  }
}
