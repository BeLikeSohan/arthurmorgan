import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static Future<bool> isLoggedInBefore() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      return prefs.getBool("isLoggedInBefore")!;
    } catch (e) {
      return false;
    }
  }

  static void setIsLoggedInBefore(bool _) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedInBefore", _);
  }

  static Future<String> getOAuthJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("oAuthJson")!;
  }

  static void setOAuthJson(String oAuthJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("oAuthJson", oAuthJson);
  }
}
