import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _keyRecentId = "recent_id_key";
  static const String _keyRememberMe = "remember_me_key";
  static const String buildNumber = "1"; // 예시로 build number 를 "1" 로 지정합니다.

  static Future<String> getRecentIdLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? recentId = prefs.getString("${_keyRecentId}_$buildNumber");
    return recentId ?? "";
  }

  static Future<void> setRecentIdLocal(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("${_keyRecentId}_$buildNumber", value);
  }

  static Future<bool> getRememberMeLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? rememberMe = prefs.getBool("${_keyRememberMe}_$buildNumber");
    return rememberMe ?? true;
  }

  static Future<void> setRememberMeLocal(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("${_keyRememberMe}_$buildNumber", value);
  }
}
