import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../models/survey/question_model.dart';
import 'survey_location_map_picker.dart';
import 'survey_question_card.dart';

/// GPS question wrapper. Emits `{latitude, longitude}` map so the backend
/// receives a JSON object identical to the web frontend's payload.
class SurveyGpsField extends StatelessWidget {
  final Question question;
  final Map? value; // {'latitude': [double], 'longitude': [double]}
  final ValueChanged<Map<String, dynamic>?> onChanged;
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
    var lat = v['latitude'];
    var lng = v['longitude'];

    // Handle array format from backend
    if (lat is List && lat.isNotEmpty) lat = lat.first;
    if (lng is List && lng.isNotEmpty) lng = lng.first;

    // Support both numbers and strings (some routes return/expect strings)
    final latNum = lat is num ? lat.toDouble() : double.tryParse(lat.toString());
    final lngNum = lng is num ? lng.toDouble() : double.tryParse(lng.toString());

    if (latNum != null && lngNum != null) return LatLng(latNum, lngNum);
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
            onChanged({
              'latitude': [ll.latitude.toString()],
              'longitude': [ll.longitude.toString()],
            });
          }
        },
      ),
    );
  }
}
