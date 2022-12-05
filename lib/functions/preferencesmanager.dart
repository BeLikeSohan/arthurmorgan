import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? prefs;

class PreferencesManager {
  static void init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> isLoggedInBefore() async {
    try {
      return prefs!.getBool("isLoggedInBefore")!;
    } catch (e) {
      return false;
    }
  }

  static Future<void> setIsLoggedInBefore(bool _) async {
    await prefs!.setBool("isLoggedInBefore", _);
  }

  static Future<String> getOAuthJson() async {
    return prefs!.getString("oAuthJson")!;
  }

  static void setOAuthJson(String oAuthJson) async {
    await prefs!.setString("oAuthJson", oAuthJson);
  }

  static String getThemeMode() {
    return prefs!.getString("themeMode") ?? "system";
  }

  static Future<void> setThemeMode(String themeMode) async {
    await prefs!.setString("themeMode", themeMode);
  }

  static String getWindowStyle() {
    return prefs!.getString("windowStyle") ?? "Opaque";
  }

  static Future<void> setWindowStyle(String windowStyle) async {
    await prefs!.setString("windowStyle", windowStyle);
  }

  static String? getCustomRootFolderName() {
    return prefs!.getString("customRootFolderName");
  }

  static Future<void> setCustomRootFolderName(
      String customRootFolderName) async {
    await prefs!.setString("customRootFolderName", customRootFolderName);
  }

  static Future<void> removeLoginInfo() async {
    await prefs!.remove("oAuthJson");
    await prefs!.remove("customRootFolderName");
  }
}
