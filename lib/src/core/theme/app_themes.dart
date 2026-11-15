import 'package:material_ui/material_ui.dart';

class AppThemes {
  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF6558D3),
        brightness: brightness, surface: dark ? const Color(0xFF171823) : const Color(0xFFF7F6FC));
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(backgroundColor: scheme.surface, centerTitle: false),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        minimumSize: const Size(0, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      )),
    );
  }
  static final lightTheme = _theme(Brightness.light);
  static final darkTheme = _theme(Brightness.dark);
}
