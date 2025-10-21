import 'package:memory_color/src/core/services/settings_manager.dart';
import 'package:vibration/vibration.dart';

class VibratorManager {
  final SettingsManager _settingsManager;

  VibratorManager(this._settingsManager);

  Future vibrateTap() async {
    if (_settingsManager.isVibrationEnabled && await Vibration.hasVibrator()) {
      await Vibration.vibrate(duration: 50);
    }
  }

  Future vibrateToShow() async {
    if (_settingsManager.isVibrationEnabled && await Vibration.hasVibrator()) {
      await Vibration.vibrate(duration: 50);
    }
  }

  void vibrateSuccess() async {
    if (_settingsManager.isVibrationEnabled && await Vibration.hasVibrator()) {
      await Vibration.vibrate(duration: 100);
    }
  }

  void vibrateError() async {
    if (_settingsManager.isVibrationEnabled && await Vibration.hasVibrator()) {
      await Vibration.vibrate(duration: 250);
    }
  }
}
