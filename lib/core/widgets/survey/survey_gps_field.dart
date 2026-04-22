import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../models/survey/question_model.dart';
import 'survey_location_map_picker.dart';
import 'survey_question_card.dart';

/// GPS question wrapper. Emits `{latitude, longitude}` map so the backend
/// receives a JSON object identical to the web frontend's payload.
class SurveyGpsField extends StatelessWidget {
  final Question question;
  final Map? value; // {'latitude': double, 'longitude': double}
  final ValueChanged<Map<String, double>?> onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isEditable;

  const SurveyGpsField({
    super.key,
    required this.question,
    required this.onChanged,
    this.value,
    this.errorText,
    this.isVisible = true,
    this.isEditable = true,
  });

  LatLng? get _latLng {
    final v = value;
    if (v == null) return null;
    final lat = v['latitude'];
    final lng = v['longitude'];
    if (lat is num && lng is num) return LatLng(lat.toDouble(), lng.toDouble());
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SurveyQuestionCard(
      label: question.label,
      helpText: question.helpText,
      isRequired: question.isRequired,
      errorText: errorText,
      isVisible: isVisible,
      validations: question.questionValidations,
      child: SurveyLocationMapPicker(
        value: _latLng,
        showError: errorText != null,
        disabled: !isEditable,
        onChanged: (ll) {
          if (ll == null) {
            onChanged(null);
          } else {
            onChanged({'latitude': ll.latitude, 'longitude': ll.longitude});
          }
        },
      ),
    );
  }
}
