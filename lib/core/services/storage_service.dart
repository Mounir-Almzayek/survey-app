import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  /// Bumped whenever cached Hive boxes have an incompatible shape.
  /// On startup, [SchemaMigrationService] compares this against the persisted
  /// `schema_version` SharedPreference and runs a wipe + sanitize when they differ.
  static const int currentSchemaVersion = 2;

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  static Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  static Future<void> setList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static List<String>? getList(String key) {
    return _prefs.getStringList(key);
  }

  static Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }
}

