// Under Construction

/*
Insights:
  1. The secure storage is used to store the user data securely.
  2. The user data is stored in the form of key-value pairs.
  3. Could be used to reduce the usage of IOPS.
*/

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  // Creating an instance of FlutterSecureStorage
  static const _storage = FlutterSecureStorage();

  // Declaring keys for the storage
  static const _keyUserId = 'userId';
  static const _keyUserName = 'userName';

  // Setter for userId
  static Future<void> setUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  // Getter for userId
  static Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  // Setter for userName
  static Future<void> setUserName(String userType) async {
    await _storage.write(key: _keyUserName, value: userType);
  }

  // Getter for userName
  static Future<String?> getUserName() async {
    return await _storage.read(key: _keyUserName);
  }

  // Function to clear all values
  static Future<void> clearAll() async {
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUserName);

    // await _storage.deleteAll(); // Doesn't work on certain platform
  }
}
