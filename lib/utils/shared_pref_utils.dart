import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:customer_maxx_crm/models/user.dart';

class SharedPrefUtils {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  /// Save user data to SharedPreferences
  static Future<bool> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
    await prefs.setBool(_isLoggedInKey, true);
    return true;
  }

  /// Get user data from SharedPreferences
  static Future<User?> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    
    if (!isLoggedIn) {
      return null;
    }
    
    final String? userJson = prefs.getString(_userKey);
    if (userJson == null) {
      return null;
    }
    
    try {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      return User.fromJson(userMap);
    } catch (e) {
      // If there's an error decoding, clear the stored data
      await clearUserData();
      return null;
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Clear user data from SharedPreferences
  static Future<bool> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_isLoggedInKey);
    return true;
  }
}