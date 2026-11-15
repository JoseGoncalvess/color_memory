import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static const _themeKey = 'is_dark_theme';
  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _themeMode = (_prefs.getBool(_themeKey) ?? false) ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _prefs.setBool(_themeKey, isDark);
    notifyListeners();
  }
}
