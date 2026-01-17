import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/response.dart';
import '../models/response_details.dart';

/// Local cache for responses and response details.
class ResponsesLocalRepository {
  static const String _responsesKeyPrefix = 'survey_responses_';
  static const String _responseDetailsKeyPrefix = 'response_details_';

  /// Get cached responses for a specific survey.
  static Future<List<ResponseSummary>> getCachedSurveyResponses(
    int surveyId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_responsesKeyPrefix$surveyId';
      final jsonStr = prefs.getString(key);
      if (jsonStr == null) return [];

      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((item) => ResponseSummary.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Cache responses for a specific survey.
  static Future<void> saveSurveyResponses(
    int surveyId,
    List<ResponseSummary> responses,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_responsesKeyPrefix$surveyId';
      final list = responses.map((r) => r.toJson()).toList();
      await prefs.setString(key, jsonEncode(list));
    } catch (_) {
      // ignore
    }
  }

  /// Get cached response details by id.
  static Future<ResponseDetails?> getCachedResponseDetails(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_responseDetailsKeyPrefix$id';
      final jsonStr = prefs.getString(key);
      if (jsonStr == null) return null;

      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return ResponseDetails.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Save response details to cache.
  static Future<void> saveResponseDetails(ResponseDetails details) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_responseDetailsKeyPrefix${details.id}';
      await prefs.setString(key, jsonEncode(details));
    } catch (_) {
      // ignore
    }
  }
}
