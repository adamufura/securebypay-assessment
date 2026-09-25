import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class TokenStorage {
  TokenStorage(this._prefs);

  final SharedPreferences _prefs;

  String? get token => _prefs.getString(AppConstants.tokenKey);

  bool get hasToken {
    final value = token;
    return value != null && value.isNotEmpty;
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  Future<void> clearToken() async {
    await _prefs.remove(AppConstants.tokenKey);
  }

  Map<String, dynamic>? get cachedUser {
    final raw = _prefs.getString(AppConstants.userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs.setString(AppConstants.userKey, jsonEncode(user));
  }

  Future<void> clearUser() async {
    await _prefs.remove(AppConstants.userKey);
  }

  Future<void> clearAll() async {
    await clearToken();
    await clearUser();
  }
}
