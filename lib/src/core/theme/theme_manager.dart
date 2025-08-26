// lib/src/core/theme/theme_manager.dart
import 'package:flutter/material.dart';

class ThemeManager extends ChangeNotifier {
  // A variável privada que armazena o estado atual do tema.
  ThemeMode _themeMode = ThemeMode.light;

  // O getter público para que a UI possa ler o estado atual.
  ThemeMode get themeMode => _themeMode;

  // O método que a UI chamará para alternar o tema.
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    // Notifica todos os 'ouvintes' (widgets) que o estado mudou,
    // para que eles possam se reconstruir.
    notifyListeners();
  }
}
