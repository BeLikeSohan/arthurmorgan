import 'package:arthurmorgan/functions/preferencesmanager.dart';
import 'package:arthurmorgan/functions/stylehandler.dart';
import 'package:fluent_ui/fluent_ui.dart';

class SettingsProvider extends ChangeNotifier {
  String currentThemeMode = "system";
  String currentWindowStyle = "opaque";

  void loadSettings() {
    currentThemeMode = PreferencesManager.getThemeMode();
    currentWindowStyle = PreferencesManager.getWindowStyle();
    StyleHandler.setWindowStyle(currentWindowStyle);
    notifyListeners();
  }

  void setThemeMode(String mode) async {
    currentThemeMode = mode;
    await PreferencesManager.setThemeMode(mode);
    notifyListeners();
  }

  void setWindowStyle(String style) async {
    currentWindowStyle = style;
    StyleHandler.setWindowStyle(currentWindowStyle);
    await PreferencesManager.setThemeMode(style);
    notifyListeners();
  }

  get themeMode {
    return currentThemeMode;
  }

  get windowStyle {
    return currentWindowStyle;
  }
}
