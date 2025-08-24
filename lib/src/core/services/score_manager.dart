// lib/src/core/services/score_manager.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager extends ChangeNotifier {
  static const String _highScoreKey = 'high_score';
  int _highScore = 0;
  late SharedPreferences _prefs;

  int get highScore => _highScore;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _highScore = _prefs.getInt(_highScoreKey) ?? 0;
    notifyListeners();
  }

  void checkAndSaveHighScore(int newScore) {
    if (newScore > _highScore) {
      _highScore = newScore;
      _prefs.setInt(_highScoreKey, _highScore);
      notifyListeners();
    }
  }
}
