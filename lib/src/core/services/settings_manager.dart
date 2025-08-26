// lib/src/core/services/settings_manager.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager extends ChangeNotifier {
  late SharedPreferences _prefs;
  static const String _soundKey = 'is_sound_enabled';
  static const String _vibrationKey = 'is_vibration_enabled';
  static const String _colorDimmingKey = 'is_color_dimming_enabled';
  int coutAdplay = 0;

  bool _isSoundEnabled = true;
  bool _isVibrationEnabled = true;
  bool _isColorDimmingEnabled = true;

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isVibrationEnabled => _isVibrationEnabled;
  bool get isColorDimmingEnabled => _isColorDimmingEnabled;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isSoundEnabled = _prefs.getBool(_soundKey) ?? true;
    _isVibrationEnabled = _prefs.getBool(_vibrationKey) ?? true;
    _isColorDimmingEnabled = _prefs.getBool(_colorDimmingKey) ?? true;
    notifyListeners();
  }

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    _prefs.setBool(_soundKey, _isSoundEnabled);
    notifyListeners();
  }

  void toggleVibration() {
    _isVibrationEnabled = !_isVibrationEnabled;
    _prefs.setBool(_vibrationKey, _isVibrationEnabled);
    notifyListeners();
  }

  void toggleColorDimming() {
    _isColorDimmingEnabled = !_isColorDimmingEnabled;
    _prefs.setBool(_colorDimmingKey, _isColorDimmingEnabled);
    notifyListeners();
  }

  bool adPresentView() {
    coutAdplay = _prefs.getInt("acoutPLay") ?? 0;
    if (coutAdplay == 3) {
      coutAdplay = 0;
      _prefs.setInt("acoutPLay", coutAdplay);
      return true;
    } else {
      coutAdplay++;
      _prefs.setInt("acoutPLay", coutAdplay);
      return false;
    }
  }
}
