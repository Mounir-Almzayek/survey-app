import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/custody_record.dart';

/// Repository for custody local storage operations
class CustodyLocalRepository {
  static const String _custodyRecordsKey = 'custody_records';
  static const String _custodyRecordPrefix = 'custody_record_';

  /// Get all custody records from local storage
  static Future<List<CustodyRecord>> getCustodyRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getStringList(_custodyRecordsKey) ?? [];

      return recordsJson
          .map(
            (json) => CustodyRecord.fromJson(
              jsonDecode(json) as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Save custody records to local storage
  static Future<void> saveCustodyRecords(List<CustodyRecord> records) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = records
          .map((record) => jsonEncode(record.toJson()))
          .toList();

      await prefs.setStringList(_custodyRecordsKey, recordsJson);

      // Also save individual records for quick access
      for (final record in records) {
        await prefs.setString(
          '$_custodyRecordPrefix${record.id}',
          jsonEncode(record.toJson()),
        );
      }
    } catch (e) {
      // Ignore errors in local storage
    }
  }

  /// Get a specific custody record by ID from local storage
  static Future<CustodyRecord?> getCustodyRecordById(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordJson = prefs.getString('$_custodyRecordPrefix$id');

      if (recordJson != null) {
        return CustodyRecord.fromJson(
          jsonDecode(recordJson) as Map<String, dynamic>,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Save a specific custody record to local storage
  static Future<void> saveCustodyRecord(CustodyRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save individual record
      await prefs.setString(
        '$_custodyRecordPrefix${record.id}',
        jsonEncode(record.toJson()),
      );

      // Update the list
      final records = await getCustodyRecords();
      final index = records.indexWhere((r) => r.id == record.id);
      if (index >= 0) {
        records[index] = record;
      } else {
        records.add(record);
      }

      await saveCustodyRecords(records);
    } catch (e) {
      // Ignore errors in local storage
    }
  }

  /// Clear all custody records from local storage
  static Future<void> clearCustodyRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_custodyRecordsKey);

      // Get all keys and remove custody record keys
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_custodyRecordPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      // Ignore errors in local storage
    }
  }
}
