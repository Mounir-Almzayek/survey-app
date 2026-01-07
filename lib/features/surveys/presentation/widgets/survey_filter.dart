import 'package:flutter/material.dart';

import '../../models/survey_status.dart';

class SurveyFilter extends StatelessWidget {
  final SurveyStatus? status;
  final ValueChanged<SurveyStatus?> onStatusChanged;

  const SurveyFilter({
    super.key,
    required this.status,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<SurveyStatus?>(
        value: status,
        hint: const Text('Status'),
        onChanged: onStatusChanged,
        items: const [
          DropdownMenuItem<SurveyStatus?>(
            value: null,
            child: Text('All'),
          ),
          DropdownMenuItem<SurveyStatus>(
            value: SurveyStatus.draft,
            child: Text('Draft'),
          ),
          DropdownMenuItem<SurveyStatus>(
            value: SurveyStatus.published,
            child: Text('Published'),
          ),
          DropdownMenuItem<SurveyStatus>(
            value: SurveyStatus.archived,
            child: Text('Archived'),
          ),
        ],
      ),
    );
  }
}


