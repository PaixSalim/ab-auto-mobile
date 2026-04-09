import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }


  // Auth
  static String? get token => _prefs.getString('auth_token');
  static String? get userId => _prefs.getString('user_id');
  static String? get userFullName => _prefs.getString('user_full_name');
  static String? get userEmail => _prefs.getString('user_email');
  static String? get userPhone => _prefs.getString('user_phone');
  static bool get isLoggedIn => token != null;

  static Future<void> saveAuth({
    required String token,
    required String fullName,
    required String email,
    String? phone,
    String? userId,
  }) async {
    await _prefs.setString('auth_token', token);
    if (userId != null) {
      await _prefs.setString('user_id', userId);
    }
    await _prefs.setString('user_full_name', fullName);
    await _prefs.setString('user_email', email);
    if (phone != null) {
      await _prefs.setString('user_phone', phone);
    }
  }

  static Future<void> clearAuth() async {
    await _prefs.remove('auth_token');
    await _prefs.remove('user_id');
    await _prefs.remove('user_full_name');
    await _prefs.remove('user_email');
    await _prefs.remove('user_phone');
  }
}
