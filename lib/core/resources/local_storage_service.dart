import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }


  // Auth
  static String? get token => _prefs.getString('auth_token');
  static String? get userFullName => _prefs.getString('user_full_name');
  static String? get userEmail => _prefs.getString('user_email');
  static bool get isLoggedIn => token != null;

  static Future<void> saveAuth({
    required String token,
    required String fullName,
    required String email,
  }) async {
    await _prefs.setString('auth_token', token);
    await _prefs.setString('user_full_name', fullName);
    await _prefs.setString('user_email', email);
  }

  static Future<void> clearAuth() async {
    await _prefs.remove('auth_token');
    await _prefs.remove('user_full_name');
    await _prefs.remove('user_email');
  }
}
