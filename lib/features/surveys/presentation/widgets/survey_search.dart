import 'package:flutter/material.dart';

class SurveySearch extends StatelessWidget {
  final String query;
  final ValueChanged<String> onChanged;

  const SurveySearch({
    super.key,
    required this.query,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search),
        hintText: 'Search surveys',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }
}


