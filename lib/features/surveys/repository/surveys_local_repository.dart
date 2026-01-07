import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/assignment.dart';
import '../models/survey.dart';

/// Local repository for caching surveys & assignments.
class SurveysLocalRepository {
  static const String _assignmentsKey = 'surveys_assigned_assignments';
  static const String _surveysKey = 'surveys_cache';

  /// Get cached assignments list (researcher assignments).
  static Future<List<Assignment>> getCachedAssignments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = prefs.getStringList(_assignmentsKey) ?? [];

      return listJson
          .map(
            (jsonStr) => Assignment.fromJson(
              jsonDecode(jsonStr) as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Cache assignments list.
  static Future<void> saveAssignments(List<Assignment> assignments) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = assignments.map((a) => jsonEncode(a.toJson())).toList();
      await prefs.setStringList(_assignmentsKey, listJson);
    } catch (_) {
      // ignore local storage errors
    }
  }

  /// Get cached survey details by id, if present.
  static Future<Survey?> getCachedSurvey(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final surveysJson = prefs.getStringList(_surveysKey) ?? [];
      for (final jsonStr in surveysJson) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        if (map['id'] == id) {
          return Survey.fromJson(map);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Save or update a survey in cache.
  static Future<void> saveSurvey(Survey survey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final surveysJson = prefs.getStringList(_surveysKey) ?? [];
      final List<Map<String, dynamic>> maps = surveysJson
          .map((s) => jsonDecode(s) as Map<String, dynamic>)
          .toList();

      final index = maps.indexWhere((m) => m['id'] == survey.id);
      if (index >= 0) {
        maps[index] = survey.toJson();
      } else {
        maps.add(survey.toJson());
      }

      await prefs.setStringList(
        _surveysKey,
        maps.map((m) => jsonEncode(m)).toList(),
      );
    } catch (_) {
      // ignore local storage errors
    }
  }
}
