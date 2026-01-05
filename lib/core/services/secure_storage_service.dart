import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Storage Service
/// 
/// Provides secure storage using FlutterSecureStorage (encrypted storage)
/// Suitable for storing sensitive data like keys, tokens, and credentials
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    // Android options
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    // iOS options
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Write a string value securely
  /// 
  /// Parameters:
  /// - [key]: The key to store the value under
  /// - [value]: The string value to store
  /// 
  /// Returns: Future that completes when the value is stored
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read a string value securely
  /// 
  /// Parameters:
  /// - [key]: The key to read the value from
  /// 
  /// Returns: The stored string value, or null if not found
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Delete a value by key
  /// 
  /// Parameters:
  /// - [key]: The key to delete
  /// 
  /// Returns: Future that completes when the value is deleted
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Delete all stored values
  /// 
  /// Returns: Future that completes when all values are deleted
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Check if a key exists
  /// 
  /// Parameters:
  /// - [key]: The key to check
  /// 
  /// Returns: true if the key exists, false otherwise
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  /// Read all stored keys and values
  /// 
  /// Returns: Map of all stored key-value pairs
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }
}

